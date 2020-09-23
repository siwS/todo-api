require 'rails_helper'

RSpec.describe User, type: :model do

  let!(:user) { create(:user, username: "test-user") }

  describe "creation" do
    it "cannot create two users with the same username" do
      expect { User.create!(username: "test-user", password: "p@ssW0rd") }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "validation" do
    it "cannot have a username with invalid characters" do
      expect { User.create!(username: "test-user@invalid", password: "p@ssW0rd") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
