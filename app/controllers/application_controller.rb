class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController
  include ::JwtAuthenticatable
  include ::Error::ErrorHandler

  before_action :authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def context
    { user: logged_in_user }
  end
end
