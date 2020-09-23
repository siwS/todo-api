class User < ApplicationRecord
  has_secure_password

  validates :username, format: /\A[A-Za-z0-9_-]*\z/
end
