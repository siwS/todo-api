class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'

    create_table :users, id: :uuid do |t|
      t.string :username
      t.string :password_digest
      t.index ["username"], unique: true

      t.timestamps
    end
  end
end
