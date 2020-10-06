class Task < ApplicationRecord
  include ::Taggable

  belongs_to :user

  validates_presence_of :title

  accepts_nested_attributes_for :tags

end
