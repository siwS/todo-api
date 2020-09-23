FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(separators: %w(_ -))  }
    password  { Faker::Internet.password  }
  end
end
