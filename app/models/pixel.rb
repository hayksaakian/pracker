class Pixel
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :hits

  field :code, type: String
end