require "rails_helper"

RSpec.describe "Tasks management" do
  let(:user) { create(:user, username: "test-user") }
  let(:bearer_token) { JWT.encode({ user_id: user.id }, Rails.application.secrets.jwt_key) }

  let!(:task) { create(:task, title: "Pay Electricity bill", user: user) }
  let!(:tag) { create(:tag, user: user, name: "Bills") }

  let!(:task_does_not_belong_to_user) { create(:task, title: "Maths assignment") }

  let(:headers) do
    {
      "Content-Type"  => "application/vnd.api+json",
      "Authorization" => "Bearer #{bearer_token}"
    }
  end

  describe "#index" do
    it "checks for user authentication" do
      get "/api/v1/tasks", :headers => { "Content-Type" => "application/vnd.api+json" }
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

    context "pagination" do
      let!(:tasks) { create_list(:task, 29, user: user) }

      it "returns a paginated list of task results with default pagination size" do
        get "/api/v1/tasks", :headers => headers
        expect(response.body).to have_json_type(Array).at_path("data")

        data = JSON.parse(response.body)["data"]
        expect(data.count).to eq(20)

        links = JSON.parse(response.body)["links"]
        expect(URI.decode(links["first"])).to end_with("api/v1/tasks?page[number]=1&page[size]=20")
        expect(URI.decode(links["last"])).to end_with("api/v1/tasks?page[number]=2&page[size]=20")
        expect(URI.decode(links["next"])).to end_with("api/v1/tasks?page[number]=2&page[size]=20")
      end

      it "returns the second page of the task results with default pagination size" do
        get "/api/v1/tasks?page[number]=2", :headers => headers
        expect(response.body).to have_json_type(Array).at_path("data")

        data = JSON.parse(response.body)["data"]
        expect(data.count).to eq(10)

        links = JSON.parse(response.body)["links"]
        expect(URI.decode(links["first"])).to end_with("api/v1/tasks?page[number]=1&page[size]=20")
        expect(URI.decode(links["last"])).to end_with("api/v1/tasks?page[number]=2&page[size]=20")
        expect(links["next"]).to be_nil
      end

      it "accepts a parameter for page size" do
        get "/api/v1/tasks?page[number]=2&page[size]=5", :headers => headers
        expect(response.body).to have_json_type(Array).at_path("data")

        data = JSON.parse(response.body)["data"]
        expect(data.count).to eq(5)

        links = JSON.parse(response.body)["links"]
        expect(URI.decode(links["first"])).to end_with("api/v1/tasks?page[number]=1&page[size]=5")
        expect(URI.decode(links["last"])).to end_with("api/v1/tasks?page[number]=6&page[size]=5")
        expect(URI.decode(links["next"])).to end_with("api/v1/tasks?page[number]=3&page[size]=5")
      end
    end
  end

  describe "#show" do
    it "checks for user authentication" do
      get "/api/v1/tasks/#{task.id}", :headers => { "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow showing another user's task" do
      get "/api/v1/tasks/#{task_does_not_belong_to_user.id}", :headers => headers
      expect(response).to have_http_status(:forbidden)
    end

    it "returns a task that belongs to user" do
      get "/api/v1/tasks/#{task.id}", :headers => headers
      expect(response).to have_http_status(:ok)
    end

    it "returns the fields for a task with correct values" do
      get "/api/v1/tasks/#{task.id}", :headers => headers
      assert_json_api_format_for_single_record(response)
    end

    it "handles not found errors" do
      get "/api/v1/tasks/12c8490d-762d-4e0f-a858-ec2d10104a82", :headers => headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#relationships" do
    it "gets the tags for a task" do
      task.tags << tag
      get "/api/v1/tasks/#{task.id}/relationships/tags", :headers => headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to have_json_type(Array).at_path("data")

      data = JSON.parse(response.body)["data"]
      expect(data.count).to eq(1)
      expect(data.first["type"]).to eq("tags")
      expect(data.first["id"]).to eq(tag.id)
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
      post "/api/v1/tasks", :params => create_task_params.to_json, :headers => { "Content-Type" => "application/vnd.api+json" }
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
      patch "/api/v1/tasks/#{task.id}", :params => update_task_params.to_json, :headers => { "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not allow updating another user's task" do
      patch "/api/v1/tasks/#{task_does_not_belong_to_user.id}", :params => update_task_params.to_json, :headers => headers
      expect(response).to have_http_status(:forbidden)
      expect(task_does_not_belong_to_user.reload.title).to eq("Maths assignment")
    end

    it "updates an existing task" do
      expect(task.title).to eq("Pay Electricity bill")

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
      expect(task.reload.tags.map(&:name).sort).to eq(["Tomorrow", "Bills"].sort)
    end

    it "handles not found errors" do
      patch "/api/v1/tasks/12c8490d-762d-4e0f-a858-ec2d10104a82", :params => update_task_params_with_existing_tags.to_json, :headers => headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#delete" do
    it "checks for user authentication" do
      delete "/api/v1/tasks/#{task.id}", :headers => { "Content-Type" => "application/vnd.api+json" }
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

    it "handles not found errors" do
      delete "/api/v1/tasks/12c8490d-762d-4e0f-a858-ec2d10104a82", :headers => headers
      expect(response).to have_http_status(:not_found)
    end
  end

  def load_task_from_response(response)
    body = JSON.parse(response.body)
    Task.find(body["data"]["id"])
  end

  def assert_json_api_format_for_single_record(response)
    expect(response.body).to have_json_path("data/id")
    expect(response.body).to have_json_path("data/type")
    expect(response.body).to have_json_path("data/links")
    expect(response.body).to have_json_path("data/attributes")
    expect(response.body).to have_json_path("data/relationships")
  end
end