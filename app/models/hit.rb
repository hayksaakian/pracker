class Hit
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :pixel#, touch: true
  embeds_one :geo
  embeds_one :device

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

  end
  def analyze_device
    
  end
end
