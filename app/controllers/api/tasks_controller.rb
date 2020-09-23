class Api::TasksController < ApplicationController
  before_action :add_required_filter, only: [:index]
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

    params["data"]["relationships"] = ::Api::ParametersService.create_tags_relationship(tags_attribute, logged_in_user)
    params["data"]["attributes"].delete("tags")
  end

  def add_required_filter
    params["filter"] = { user_id: logged_in_user.id }
  end
end
