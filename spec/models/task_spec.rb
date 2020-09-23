require 'rails_helper'

RSpec.describe Tag, type: :model do
  let!(:tag_1) { create(:tag, name: "Bills") }
  let!(:tag_2) { create(:tag, name: "Shared") }

  let!(:task_1) { create(:task, title: "Electricity bill")}
  let!(:task_2) { create(:task, title: "Internet bill")}

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
