class Api::TagsController < ApplicationController
  before_action :ensure_belongs_to_user, only: [:update]

  def ensure_belongs_to_user
    @tag = Tag.find(params[:id])
    head :forbidden unless @tag.user == logged_in_user
  end
end
