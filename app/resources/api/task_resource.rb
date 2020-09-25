class Api::TaskResource < JSONAPI::Resource
  attributes :title
  key_type :uuid

  filter :user_id

  has_many :tags, acts_as_set: true

  before_create :set_user_from_context

  def set_user_from_context
    @model.user = @context[:user]
  end
end