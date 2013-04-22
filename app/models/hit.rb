class Hit
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :pixel#, touch: true

  field :referrer, type: String
  field :agent, type: String
  field :request_ip, type: String

  field :clicked, type: Boolean
end
