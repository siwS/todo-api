class Task < ApplicationRecord
  include ::Taggable

  belongs_to :user
end
