class CreateTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :taggings do |t|
      t.belongs_to :tag, foreign_key: true

      t.timestamps
    end

    add_reference :taggings, :taggable, polymorphic: true, index: true
  end
end
