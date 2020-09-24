require 'rails_helper'

class AuthenticatedController < ActionController::Base
  include ::JwtAuthenticatable
end

RSpec.describe AuthenticatedController, :type => :controller do
  let(:expected_response) { {"errors"=>[{"status"=>"unauthorized", "title"=>"unauthorized", "detail"=>"Please log in"}]}.to_json }

  let(:user) { create(:user, username: "test-user") }
  let(:bearer_token) { JWT.encode({ user_id: user.id }, Rails.application.secrets.jwt_key) }

  let(:headers) do
    {
      "Content-Type"  => "application/vnd.api+json",
      "Authorization" => "Bearer #{bearer_token}"
    }
  end

  controller do
    before_action :authorized

    def index
      render json: { message: "Successfully executed" }
    end
  end

  it "returns an error on unauthenticated requests" do
    get :index
    expect(response.body).to be_json_eql(expected_response)
  end

  it "returns an error on unauthenticated requests" do
    request.headers.merge!(headers)
    get :index, xhr: true
    expect(response.body).to be_json_eql({"message": "Successfully executed"}.to_json)
  end
end
