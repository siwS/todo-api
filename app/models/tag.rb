class Tag < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :destroy
end
