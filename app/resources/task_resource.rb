class TaskResource < JSONAPI::Resource
  attributes :title
  has_many :tags

  before_create :add_user

  def add_user
    @model.user = @context[:user]
  end
end