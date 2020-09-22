class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Use created_at to sort records instead of IDs, because of use of UUIDs.
  self.implicit_order_column = :created_at
end
