class Api::TaskResource < JSONAPI::Resource
  attributes :title
  has_many :tags

  before_create :set_user_from_context

  def set_user_from_context
    @model.user = @context[:user]
  end
end