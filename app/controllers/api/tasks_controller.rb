class Api::TasksController < ApplicationController
  before_action :filter_by_user, only: [:index]
  before_action :ensure_belongs_to_user, only: [:update, :destroy, :show]
  before_action :transform_tags_attribute_to_relationship, only: [:update]

  def ensure_belongs_to_user
    @task = Task.find(params[:id])
    head :forbidden unless @task.user == logged_in_user
  end

  # Backwards support for tags as attributes.
  def transform_tags_attribute_to_relationship
    tags_attribute = params["data"]["attributes"]["tags"]
    return unless tags_attribute.present?

    params["data"]["relationships"] = create_tags_relationship_hash(tags_attribute)
    params["data"]["attributes"].delete("tags")
  end

  def filter_by_user
    params["filter"] = { user_id: logged_in_user.id }
  end

  private

  def create_tags_relationship_hash(tags_attribute)
    tag_records = tags_attribute.map { |tag| Tag.find_or_create_by(name: tag, user: logged_in_user) }
    json        = tag_records.map { |tag| { type: "tags", id: tag.id } }

    {
      "tags": {
        "data": json
      }
    }
  end
end
