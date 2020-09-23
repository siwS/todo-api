class Api::TagsController < ApplicationController
  before_action :ensure_belongs_to_user, only: [:update, :destroy, :show]
  before_action :filter_by_user, only: [:index]

  def ensure_belongs_to_user
    @tag = Tag.find(params[:id])
    head :forbidden unless @tag.user == logged_in_user
  end

  def filter_by_user
    params["filter"] = { user_id: logged_in_user.id }
  end
end
