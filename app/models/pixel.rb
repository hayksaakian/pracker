class Pixel
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :hits

  field :code, type: String
  field :target_url, type: String
  
  def uniques
  	self.hits.distinct(:request_ip) || []
  end
  def clicks
  	self.hits.where(:clicked => true) || []
  end
  def unique_clicks
  	self.hits.where(:clicked => true).distinct(:request_ip) || []
  end
  def ctr
    self.clicks.count > 0 ? (self.clicks.count / self.hits.count) * 100.00 : 0.000
  end
end