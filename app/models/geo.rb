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
  
end