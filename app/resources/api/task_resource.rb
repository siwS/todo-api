class Api::TaskResource < JSONAPI::Resource
  attributes :title, :created_at, :tags
  key_type :uuid

  filter :user_id

  before_create :set_user_from_context

  def set_user_from_context
    @model.user = @context[:user]
  end

  def tags
    @model.tags.map(&:name)
  end

  def tags=(new_tags)
    tags         = Tag.where(name: new_tags, user: @context[:user])
    missing_tags = new_tags - tags.map(&:name)
    created_tags = missing_tags.map { |tag_name| Tag.create(name: tag_name, user: @context[:user]) }
    @model.tags  = tags + created_tags
  end
end