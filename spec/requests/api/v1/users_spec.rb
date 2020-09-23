require "rails_helper"

RSpec.describe "Users management" do
  let!(:user) { create(:user, username: "test-user", password: "p@$$w0rd") }
  let(:bearer_token) { JWT.encode({ user_id: user.id }, Rails.application.secrets.jwt_key) }

  let(:headers) do
    {
      "Content-Type"  => "application/vnd.api+json",
      "Authorization" => "Bearer #{bearer_token}"
    }
  end

  describe "#create" do
    let(:username) { Faker::Internet.username(separators: %w(_ -)) }
    let(:new_user_params) do
      {
        username: username,
        password: Faker::Internet.password
      }
    end

    it "creates a new user" do
      expect do
        post "/api/v1/users", params: new_user_params
      end.to change { User.count }.by(1)
      expect(response).to have_http_status(:created)
      assert_json_api_format_for_single_record(response)
    end

    context "existing username" do
      let(:username) { user.username }

      it "does not allow to use an existing username" do
        expect do
          post "/api/v1/users", params: new_user_params
        end.not_to change { User.count }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "invalid username" do
      let(:username) { "inv@l1d_username&" }

      it "does not allow to use an invalid username" do
        expect do
          post "/api/v1/users", params: new_user_params
        end.not_to change { User.count }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#login" do
    let(:login_params) do
      {
        username: user.username,
        password: password
      }
    end

    context "correct password" do
      let(:password) { "p@$$w0rd" }

      it "logs in the user" do
        post "/api/v1/login", params: login_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "wrong password" do
      let(:password) { "wrong password" }

      it "fails to log in the user" do
        post "/api/v1/login", params: login_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  def assert_json_api_format_for_single_record(response)
    expect(response.body).to have_json_path("data/id")
    expect(response.body).to have_json_path("data/type")
    expect(response.body).to have_json_path("data/attributes")
  end
end