require 'rails_helper'

class ControllerWithError < ActionController::Base
  include ::Error::ErrorHandler
end

RSpec.describe ControllerWithError, :type => :controller do
  let(:expected_not_found_response) { {"errors"=>[{"status"=>"not_found", "title"=>"record_not_found", "detail"=>"ActiveRecord::RecordNotFound"}]}.to_json }

  controller do
    def index
      raise ActiveRecord::RecordNotFound
    end
  end

  it "rescues from RecordNotFound" do
    get :index
    expect(response.body).to be_json_eql(expected_not_found_response)
  end
end
