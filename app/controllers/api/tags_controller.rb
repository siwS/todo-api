class Api::TagsController < ApplicationController
  before_action :ensure_belongs_to_user, only: [:update, :destroy, :show]
  before_action :add_required_filter, only: [:index]

  def ensure_belongs_to_user
    @tag = Tag.find(params[:id])
    head :forbidden unless @tag.user == logged_in_user
  end

  def add_required_filter
    params["filter"] = { user_id: logged_in_user.id }
  end
end
