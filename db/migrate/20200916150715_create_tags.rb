class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags, id: :uuid do |t|
      t.string :name
      t.references :user, type: :uuid

      t.timestamps
    end
  end
end
