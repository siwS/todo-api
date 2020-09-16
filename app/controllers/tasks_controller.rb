class TasksController < ApplicationController
  before_action :ensure_belongs_to_user, only: [:update]

  def ensure_belongs_to_user
    @task = Task.find(params[:id])
    head :forbidden unless @task.user == logged_in_user
  end
end
