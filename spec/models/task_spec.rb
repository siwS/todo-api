require 'rails_helper'

RSpec.describe Tag, type: :model do
  let!(:tag_1) { create(:tag, name: "Bills") }
  let!(:tag_2) { create(:tag, name: "Shared") }

  let!(:task_1) { create(:task, title: "Electricity bill")}
  let!(:task_2) { create(:task, title: "Internet bill")}

  describe "creation" do
    it "has a UUID as primary key" do
      expect(task_1.id.length).to eq(36)
      expect(task_1.id).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
    end
  end

  describe "deletion" do
    it "destroys dependent taggings when a task is deleted" do
      task_1.tags << [tag_1, tag_2]
      task_2.tags << [tag_1]

      expect(Task.all.count).to eq(2)
      expect(Tagging.all.count).to eq(3)
      expect(Tag.all.count).to eq(2)

      task_1.destroy!

      expect(Task.all.count).to eq(1)
      expect(Tagging.all.count).to eq(1)
      expect(Tag.all.count).to eq(2)
    end
  end
end
