class Api::UsersController < ApplicationController
  before_action :authorized, only: [:auto_login]

  def create
    @user = User.create(user_params)
    if @user.valid?
      token = encode_token({ user_id: @user.id })
      render json: json_user_response(@user, token), status: :created
    else
      render json: { error: "Invalid username or password" }, status: :forbidden
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { error: "Username already taken" }, status: :forbidden
  end

  def login
    @user = User.find_by(username: params[:username])

    if @user && @user.authenticate(params[:password])
      token = encode_token({ user_id: @user.id })
      render json: json_user_response(@user, token)
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  def auto_login
    render json: @user
  end

  private

  def json_user_response(user, token)
    {
      data: {
        id:         user.username,
        type:       "users",
        attributes: {
          username: user.username,
          token:    token
        }
      }
    }
  end

  def user_params
    params.permit(:username, :password)
  end
end
