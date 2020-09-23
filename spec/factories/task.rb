FactoryBot.define do
  factory :task do
    user
    sequence(:title) { |n| "task #{n}" }
  end
end
