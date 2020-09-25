# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

user = User.create!(username: 'test-user', password: 's3cUr8p@$$w0rD<>')

30.times do |i|
  Task.create!(title: "title-#{i}", user: user)
end

30.times do |i|
  Tag.create!(name: "name-#{i}", user: user)
end