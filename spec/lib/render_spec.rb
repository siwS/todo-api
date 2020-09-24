require "rails_helper"

RSpec.describe Error::Helpers::Render do
  let(:expected_not_found_response) { {"errors"=>[{"status"=>"not_found", "title"=>"not_found", "detail"=>"Task with id=1 not found."}]}.to_json }

  it "creates a JSON:API compliant error response" do
    error_json = Error::Helpers::Render.json(:not_found, :not_found, "Task with id=1 not found.").to_json
    expect(error_json).to be_json_eql(expected_not_found_response)
  end
end