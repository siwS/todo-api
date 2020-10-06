class Api::TasksController < ApplicationController
  before_action :add_required_filter, only: [:index]
  before_action :ensure_belongs_to_user, only: [:update, :destroy, :show]

  def ensure_belongs_to_user
    @task = Task.find(params[:id])
    head :forbidden unless @task.user == logged_in_user
  end

  def add_required_filter
    params["filter"] = params["filter"] || {}
    params["filter"][:user_id] = logged_in_user.id
  end
end
