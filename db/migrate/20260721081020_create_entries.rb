class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.text :body, null: false
      t.string :link

      t.timestamps
    end
  end
end
