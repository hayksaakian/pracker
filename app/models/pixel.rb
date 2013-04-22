class Pixel
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :hits

  field :code, type: String
  field :target_url, type: String
  
  def uniques
  	self.hits.distinct(:request_ip) || []
  end
end