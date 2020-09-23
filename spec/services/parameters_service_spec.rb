require 'rails_helper'

RSpec.describe Api::ParametersService, type: :service do
  describe "parameters transformation" do
    let(:user) { create(:user) }

    context "with new tags" do
      let(:tags) { ["Bills", "Homework"] }

      it "creates a hash with expected structure for a JSON:API relationship" do
        expect do
          res = Api::ParametersService.create_tags_relationship(tags, user)
          expect(res.to_json).to have_json_type(Array).at_path("tags/data")

          data = res[:tags][:data]
          expect(data.count).to eq(2)
          expect(data.first.to_json).to have_json_type(String).at_path("id")
          expect(data.first[:type]).to eq("tags")

        end.to change { Tag.count }.by(2)
      end
    end

    context "with tag that already exists" do
      let!(:tag) { create(:tag, name: "Groceries", user: user) }
      let(:tags) { ["Bills", "Groceries"] }

      it "does not recreate existing tag" do
        expect do
          res = Api::ParametersService.create_tags_relationship(tags, user)
          expect(res.to_json).to have_json_type(Array).at_path("tags/data")

          data = res[:tags][:data]
          expect(data.count).to eq(2)
          expect(data.first.to_json).to have_json_type(String).at_path("id")
          expect(data.first[:type]).to eq("tags")

        end.to change { Tag.count }.by(1)
      end
    end
  end
end