class Api::TagResource < JSONAPI::Resource
  attributes :name
  key_type :uuid

  filter :user_id

  before_create :set_user_from_context

  def set_user_from_context
    @model.user = @context[:user]
  end
end