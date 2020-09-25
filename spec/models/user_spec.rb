require 'rails_helper'

RSpec.describe User, type: :model do

  let!(:user) { create(:user, username: "test-user") }

  describe "creation" do
    it "cannot create two users with the same username" do
      expect { User.create!(username: "test-user", password: "p@ssW0rd") }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "has a UUID as primary key" do
      expect(user.id.length).to eq(36)
      expect(user.id).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
    end
  end

  describe "validation" do
    it "cannot have a username with invalid characters" do
      expect { User.create!(username: "test-user@invalid", password: "p@ssW0rd") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
