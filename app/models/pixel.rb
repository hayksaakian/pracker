class Pixel
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :hits

  field :code, type: String
  
  def uniques
  	self.hits.distinct(:request_ip)
  end
end