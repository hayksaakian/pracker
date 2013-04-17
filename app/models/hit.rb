class Hit
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :pixel

  field :referrer, type: String
  field :agent, type: String
  field :request_ip, type: String
end
