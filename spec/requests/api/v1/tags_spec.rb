require "rails_helper"

RSpec.describe "Tags management" do
  let(:user) { create(:user, username: "test-user") }
  let(:bearer_token) { JWT.encode({ user_id: user.id }, Rails.application.secrets.jwt_key) }

  let!(:tag) { create(:tag, user: user) }
  let!(:tag_does_not_belong_to_user) { create(:tag, name: "Second user tag") }

  let(:headers) do
    {
      "Content-Type"  => "application/vnd.api+json",
      "Authorization" => "Bearer #{bearer_token}"
    }
  end

  describe "#index" do
    it "checks for user authentication" do
      get "/api/v1/tags", :headers => { "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns only the tags for the logged in user" do
      get "/api/v1/tags", :headers => headers
      expect(response).to have_http_status(:ok)

      expect(response.body).to have_json_type(Array).at_path("data")

      expect(Tag.count).to eq(2)

      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(1)
      expect(data.first["id"]).to eq(tag.id)
    end

    context "pagination" do
      let!(:tags) { create_list(:tag, 29, user: user) }

      it "returns a paginated list of tags results" do
        get "/api/v1/tags", :headers => headers
        expect(response.body).to have_json_type(Array).at_path("data")

        data = JSON.parse(response.body)["data"]
        expect(data.count).to eq(20)

        links = JSON.parse(response.body)["links"]
        expect(URI.decode(links["first"])).to end_with("api/v1/tags?page[number]=1&page[size]=20")
        expect(URI.decode(links["last"])).to end_with("api/v1/tags?page[number]=2&page[size]=20")
        expect(URI.decode(links["next"])).to end_with("api/v1/tags?page[number]=2&page[size]=20")
      end

      it "returns the second page of the tags results" do
        get "/api/v1/tags?page[number]=2", :headers => headers
        expect(response.body).to have_json_type(Array).at_path("data")

        data = JSON.parse(response.body)["data"]
        expect(data.count).to eq(10)

        links = JSON.parse(response.body)["links"]
        expect(URI.decode(links["first"])).to end_with("api/v1/tags?page[number]=1&page[size]=20")
        expect(URI.decode(links["last"])).to end_with("api/v1/tags?page[number]=2&page[size]=20")
        expect(links["next"]).to be_nil
      end

      it "accepts a parameter for page size" do
        get "/api/v1/tags?page[number]=2&page[size]=5", :headers => headers
        expect(response.body).to have_json_type(Array).at_path("data")

        data = JSON.parse(response.body)["data"]
        expect(data.count).to eq(5)

        links = JSON.parse(response.body)["links"]
        expect(URI.decode(links["first"])).to end_with("api/v1/tags?page[number]=1&page[size]=5")
        expect(URI.decode(links["last"])).to end_with("api/v1/tags?page[number]=6&page[size]=5")
        expect(URI.decode(links["next"])).to end_with("api/v1/tags?page[number]=3&page[size]=5")
      end
    end
  end

  describe "#show" do
    it "checks for user authentication" do
      get "/api/v1/tags/#{tag.id}", :headers => { "Content-Type"  => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow showing another user's tag" do
      get "/api/v1/tags/#{tag_does_not_belong_to_user.id}", :headers => headers
      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow showing another user's tag" do
      get "/api/v1/tags/#{tag.id}", :headers => headers
      expect(response).to have_http_status(:ok)
    end

    it "returns the fields for a tag" do
      get "/api/v1/tags/#{tag.id}", :headers => headers
      assert_json_api_format_for_single_record(response)
      attributes = JSON.parse(response.body)["data"]["attributes"]
      expect(attributes["name"]).to eq(tag.name)
    end

    it "handles not found errors" do
      get "/api/v1/tags/12c8490d-762d-4e0f-a858-ec2d10104a82", :headers => headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#new" do
    let(:create_tag_params) do
      {
        "data":
          {
            "type":       "tags",
            "attributes": {
              "name": "Someday"
            }
          }
      }
    end

    it "checks for user authentication" do
      post "/api/v1/tags", :params => create_tag_params.to_json, :headers => { "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "creates a new tag for the logged in user" do
      expect do
        post "/api/v1/tags", :params => create_tag_params.to_json, :headers => headers
      end.to change { Tag.count }.by(1)

      expect(response).to have_http_status(:created)
      assert_json_api_format_for_single_record(response)

      expect(load_tag_from_response(response).name).to eq("Someday")
      expect(load_tag_from_response(response).user).to eq(user)
    end
  end

  describe "#update" do
    let(:update_tag_params) do
      {
        "data": {
          "type":       "tags",
          "id":         tag.id,

          "attributes": {
            "name": "Updated Tag Name"
          }
        }
      }
    end

    it "checks for user authentication" do
      patch "/api/v1/tags/#{tag.id}", :params => update_tag_params.to_json, :headers => { "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow updating another user's tag" do
      patch "/api/v1/tags/#{tag_does_not_belong_to_user.id}", :params => update_tag_params.to_json, :headers => headers
      expect(response).to have_http_status(:forbidden)
      expect(tag_does_not_belong_to_user.reload.name).to eq("Second user tag")
    end

    it "updates an existing tag" do
      expect do
        patch "/api/v1/tags/#{tag.id}", :params => update_tag_params.to_json, :headers => headers
      end.not_to change { Tag.count }

      expect(response).to have_http_status(:ok)
      assert_json_api_format_for_single_record(response)
      expect(tag.reload.name).to eq("Updated Tag Name")
    end

    it "handles not found errors" do
      patch "/api/v1/tags/12c8490d-762d-4e0f-a858-ec2d10104a82", :params => update_tag_params.to_json, :headers => headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#delete" do
    let!(:task) { create(:task, user: user) }

    it "checks for user authentication" do
      delete "/api/v1/tags/#{tag.id}", :headers => { "Content-Type"  => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow deleting another user's tag" do
      delete "/api/v1/tags/#{tag_does_not_belong_to_user.id}", :headers => headers
      expect(response).to have_http_status(:forbidden)
      expect(tag_does_not_belong_to_user.reload).not_to be_nil
    end

    it "deletes a tag that belongs to a user" do
      expect do
        delete "/api/v1/tags/#{tag.id}", :headers => headers
      end.to change { Tag.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "deletes a tag with its related taggings" do
      task.tags << tag
      expect do
        delete "/api/v1/tags/#{tag.id}", :headers => headers
      end.to change { Tagging.count }.by(-1)
      expect(task.reload.tags).to eq([])
    end

    it "handles not found errors" do
      delete "/api/v1/tags/12c8490d-762d-4e0f-a858-ec2d10104a82", :headers => headers
      expect(response).to have_http_status(:not_found)
    end
  end

  def load_tag_from_response(response)
    body = JSON.parse(response.body)
    Tag.find(body["data"]["id"])
  end

  def assert_json_api_format_for_single_record(response)
    expect(response.body).to have_json_path("data/id")
    expect(response.body).to have_json_path("data/type")
    expect(response.body).to have_json_path("data/links")
    expect(response.body).to have_json_path("data/attributes")
  end
end