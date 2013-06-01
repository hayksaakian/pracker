class Pixel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable

  embeds_many :hits

  field :code, type: String, default: ""
  field :target_url, type: String, default: ""

  def uniques
  	self.hits.distinct(:request_ip) || []
  end
  def uniques_after(date_or_time)
    self.hits.where(:created_at.gte => date_or_time).distinct(:request_ip) || []
  end
  def clicks
  	self.hits.where(:clicked => true) || []
  end
  def unique_clicks
  	self.hits.where(:clicked => true).distinct(:request_ip) || []
  end
  def unique_clicks_after(date_or_time)
    self.hits.where({:created_at.gte => date_or_time, :clicked => true}).distinct(:request_ip) || []
  end
  def ctr
    (self.unique_clicks.count > 0) ? ((self.unique_clicks.count * 100.00 ) / self.uniques.count) : 0.000
  end

  def self.hit_data
    return "self.id"
  end

  def self.flush(ip)
    Pixel.where(:'hits.request_ip' => ip).each do |p|
      p.hits.where(:request_ip => ip).destroy
    end
  end

  def code_or_default
    return self.code.blank? ? self.target_url : self.code
  end
  def target_url_or_default
    return self.target_url?.blank? ? self.code : self.target_url
  end
end