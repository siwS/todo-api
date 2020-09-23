require "rails_helper"

RSpec.describe "Tasks management" do
  let(:user) { create(:user, username: "test-user") }
  let(:bearer_token) { JWT.encode({ user_id: user.id }, Rails.application.secrets.jwt_key) }

  let!(:task) { create(:task, user: user) }
  let!(:tag) { create(:tag, user: user) }

  let!(:task_does_not_belong_to_user) { create(:task, title: "Second User task") }

  let(:headers) do
    {
      "Content-Type"  => "application/vnd.api+json",
      "Authorization" => "Bearer #{bearer_token}"
    }
  end

  describe "#index" do
    it "checks for user authentication" do
      get "/api/v1/tasks", :headers => { "Content-Type"  => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns only the tasks for the logged in user" do
      get "/api/v1/tasks", :headers => headers
      expect(response).to have_http_status(:ok)

      expect(response.body).to have_json_type(Array).at_path("data")

      expect(Task.count).to eq(2)

      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(1)
      expect(data.first["id"]).to eq(task.id)
    end
  end

  describe "#show" do
    it "checks for user authentication" do
      get "/api/v1/tasks/#{task.id}", :headers => { "Content-Type"  => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow showing another user's task" do
      get "/api/v1/tasks/#{task_does_not_belong_to_user.id}", :headers => headers
      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow showing another user's task" do
      get "/api/v1/tasks/#{task.id}", :headers => headers
      expect(response).to have_http_status(:ok)
    end

    it "returns the fields for a task" do
      get "/api/v1/tasks/#{task.id}", :headers => headers
      assert_json_api_format_for_single_record(response)
    end
  end

  describe "#new" do
    let(:create_task_params) do
      {
        "data": {
          "attributes": {
            "title": "Homework"
          },
          "type":       "tasks"
        }
      }
    end

    it "checks for user authentication" do
      post "/api/v1/tasks", :params => create_task_params.to_json,  :headers => { "Content-Type"  => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "creates a new task for the logged in user" do
      expect do
        post "/api/v1/tasks", :params => create_task_params.to_json, :headers => headers
      end.to change { Task.count }.by(1)

      expect(response).to have_http_status(:created)
      assert_json_api_format_for_single_record(response)

      expect(load_task_from_response(response).title).to eq("Homework")
      expect(load_task_from_response(response).user).to eq(user)
    end
  end

  describe "#update" do
    let(:update_task_params) do
      {
        "data": {
          "type":       "tasks",
          "id":         task.id,

          "attributes": {
            "title": "Updated Task Title"
          }
        }
      }
    end

    let(:update_task_params_with_tags) do
      {
        "data": {
          "type":       "tasks",
          "id":         task.id,

          "attributes": {
            "tags": ["Tomorrow", "Housework"]
          }
        }
      }
    end

    let(:update_task_params_with_existing_tags) do
      {
        "data": {
          "type":       "tasks",
          "id":         task.id,

          "attributes": {
            "tags": ["Tomorrow", "Bills"]
          }
        }
      }
    end

    it "checks for user authentication" do
      patch "/api/v1/tasks/#{task.id}", :params => update_task_params.to_json, :headers => { "Content-Type"  => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow updating another user's task" do
      patch "/api/v1/tasks/#{task_does_not_belong_to_user.id}", :params => update_task_params.to_json, :headers => headers
      expect(response).to have_http_status(:forbidden)
      expect(task_does_not_belong_to_user.reload.title).to eq("Second User task")
    end

    it "updates an existing task" do
      expect(task.title).to eq("Laundry")

      expect do
        patch "/api/v1/tasks/#{task.id}", :params => update_task_params.to_json, :headers => headers
      end.not_to change { Task.count }

      expect(response).to have_http_status(:ok)
      assert_json_api_format_for_single_record(response)
      expect(task.reload.title).to eq("Updated Task Title")
    end


    it "updates an existing task and adds new tags" do
      expect(task.tags).to eq([])

      expect do
        patch "/api/v1/tasks/#{task.id}", :params => update_task_params_with_tags.to_json, :headers => headers
      end.to change { Tag.count }.by(2)

      expect(response).to have_http_status(:ok)
      assert_json_api_format_for_single_record(response)
      expect(task.reload.tags.map(&:name).sort).to eq(["Tomorrow", "Housework"].sort)
    end

    it "does not create a new tag if one with the same name already exists" do
      expect(task.tags).to eq([])

      expect do
        patch "/api/v1/tasks/#{task.id}", :params => update_task_params_with_existing_tags.to_json, :headers => headers
      end.to change { Tag.count }.by(1)

      expect(response).to have_http_status(:ok)
      assert_json_api_format_for_single_record(response)
      expect(task.reload.tags.map(&:name)).to eq(["Tomorrow", "Bills"])
    end
  end

  describe "#delete" do
    it "checks for user authentication" do
      delete "/api/v1/tasks/#{task.id}", :headers => { "Content-Type"  => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow deleting another user's task" do
      delete "/api/v1/tasks/#{task_does_not_belong_to_user.id}", :headers => headers
      expect(response).to have_http_status(:forbidden)
      expect(task_does_not_belong_to_user.reload).not_to be_nil
    end

    it "deletes a task that belongs to a user" do
      expect do
        delete "/api/v1/tasks/#{task.id}", :headers => headers
      end.to change { Task.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "deletes a task with its related taggings" do
      task.tags << tag
      expect do
        delete "/api/v1/tasks/#{task.id}", :headers => headers
      end.to change { Tagging.count }.by(-1)
    end
  end

  def load_task_from_response(response)
    body = JSON.parse(response.body)
    Task.find(body["data"]["id"])
  end

  def assert_json_api_format_for_single_record(response)
    expect(response.body).to have_json_path("data/id")
    expect(response.body).to have_json_path("data/type")
    expect(response.body).to have_json_path("data/type")
    expect(response.body).to have_json_path("data/links")
    expect(response.body).to have_json_path("data/attributes")
    expect(response.body).to have_json_path("data/relationships")
  end
end