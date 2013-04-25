class Geo
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :hit
  field :country_code, type: String, default: ""
  field :dma_code, type: String, default: ""
  field :latitude, type: String, default: ""
  field :longitude, type: String, default: ""
  field :country_code3, type: String, default: ""
  field :area_code, type: String, default: ""
  field :country_name, type: String, default: ""
  field :postal_code, type: String, default: ""
  field :region, type: String, default: ""
  field :locality, type: String, default: ""
  
  # http://www.datasciencetoolkit.org/ip2coordinates/71.217.122.251
  # http://www.datasciencetoolkit.org/ip2coordinates/IP_ADDRESS
  # {
  #   71.217.122.251: {
  #     country_code: "US",
  #     dma_code: 0,
  #     latitude: 47.1936988830566,
  #     country_code3: "USA",
  #     area_code: 253,
  #     longitude: -122.185203552246,
  #     country_name: "United States",
  #     postal_code: "98391",
  #     region: "WA",
  #     locality: "Bonney Lake"
  #   } 
  # }
  # or
  # {
  #   71.217.122.251: null
  # }


  def to_pretty_s
    # this could be clever and terse but whatever
    results = []
    components = [:locality, :region, :postal_code, :country_code3]
    components.each do |c|
      unless self[c].blank?
        results.push(self[c])
      end
    end
    return results.join(',')
  end
end