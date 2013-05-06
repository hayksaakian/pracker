class Hit
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :pixel#, touch: true
  embeds_one :geo
  field :nice_ua, type: Hash, default: {}

  field :referrer, type: String, default: ""
  field :agent, type: String, default: ""
  field :request_ip, type: String, default: ""

  field :clicked, type: Boolean, default: false

  after_save :consider_geolocating, :consider_device_analysis

  # http://www.datasciencetoolkit.org/ip2coordinates/71.217.122.251
  # http://www.datasciencetoolkit.org/ip2coordinates/IP_ADDRESS
	# {
	# 	71.217.122.251: {
	# 		country_code: "US",
	# 		dma_code: 0,
	# 		latitude: 47.1936988830566,
	# 		country_code3: "USA",
	# 		area_code: 253,
	# 		longitude: -122.185203552246,
	# 		country_name: "United States",
	# 		postal_code: "98391",
	# 		region: "WA",
	# 		locality: "Bonney Lake"
	# 	} 
	# }
	# or
	# {
	# 	71.217.122.251: null
	# }

  def consider_geolocating
    if !self.request_ip.blank?
      if self.geo.nil? || self.geo.ip != self.request_ip
        self.geolocate
      end
    end
  end

  def geolocate
  	ip = self.request_ip.to_s
  	url = IP_LOOKUP_ENDPOINT + ip
    require 'net/http'
    response = {"ip" => ip}

    http_response = Net::HTTP.get_response(URI.parse(url))   
    if http_response.is_a?(Net::HTTPSuccess) 
      json_response = JSON.parse(http_response.body)
      response.merge!(json_response[ip]) unless json_response[ip].nil?
    end
    unless self.geo
      self.geo = Geo.new
      self.geo.save
    end
    # puts response
    self.geo.update_attributes(response)
  end

  def consider_device_analysis
    if !self.agent.blank?
      if self.nice_ua == {} || self.nice_ua['user_agent_string'] != self.agent
        self.analyze_device
      end
    end
  end
  def analyze_device
    ua = AgentOrange::UserAgent.new(self.agent)
    self.update_attribute(:nice_ua, JSON.parse(ua.to_json))
  end
  def pretty_ua
    ua = self.nice_ua == {} ? nil : self.nice_ua
    if !ua.nil?
      rtvl = ""
      # consider changing += to <<
      # TODO clean this UP. It's ugly as hell
      # if ua['device'] != nil && ua['device'] != {} && ua['device'].is_a? Hash
      #   engine = ua['device'].try(:fetch, 'engine', {})
      #   if engine.try(:fetch, 'browser', {}) != {}
      #     rtvl += engine['browser'].try(:fetch, 'name', "")
      #     version = engine['browser'].try(:fetch, 'version', {})
      #     rtvl += version.try(:fetch, 'major', "")
      #   end
      #   operating_system = ua['device'].try(:fetch, 'operating_system', {})
      #   rtvl += operating_system.try(:fetch, 'name', "")
      #   rtvl += ua['device'].try(:fetch, 'name', "")
      # end
      # rtvl += (ua['device']['engine']['browser']['name'] + " ") if ua.try(:[], 'device']['engine']['browser']['name'])
      # rtvl += (ua['device']['engine']['browser']['version']['major'] + " on a ") if ua['device']['engine']['browser']['version']['major'] != nil
      # rtvl += (ua['device']['operating_system']['name'] + " ") if ua['device']['operating_system']['name'] != nil
      # rtvl += (ua['device']['name']) if ua['device']['name'] != nil
      return rtvl
    else
      return ""
    end
  end
end