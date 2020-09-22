class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks, id: :uuid do |t|
      t.string :title
      t.references :user, type: :uuid

      t.timestamps
    end
  end
end
