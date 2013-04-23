class Hit
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :pixel#, touch: true
  embeds_one :geo

  field :referrer, type: String, default: ""
  field :agent, type: String, default: ""
  field :request_ip, type: String, default: ""

  field :clicked, type: Boolean, default: false

  # before_save :consider_geolocating

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
    if self.request_ip_changed?
      self.geolocate
    end
  end

  def geolocate
  	ip = self.request_ip.to_s
  	url = IP_LOOKUP_ENDPOINT + ip
    require 'net/http'
    response = Net::HTTP.get(URI.parse(url))
    response = JSON.parse(response)
    if response[ip] != nil 
      if self.geo
        g = self.geo
      else
        g = Geo.new
        self.geo = g
        g.save
      end
      puts response
    	g.update_attributes(response[ip])
    else
    	# no response
    end
  end
end
