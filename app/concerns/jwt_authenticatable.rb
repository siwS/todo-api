module JwtAuthenticatable

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secrets.jwt_key)
  end

  # { Authorization: 'Bearer <token>' }
  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, Rails.application.secrets.jwt_key, true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    return if logged_in?
    json = ::Error::Helpers::Render.json(:unauthorized, :unauthorized , "Please log in")
    render json: json, status: :unauthorized
  end
end