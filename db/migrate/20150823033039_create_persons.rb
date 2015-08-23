class CreatePersons < ActiveRecord::Migration
  def change
    create_table :asset_persons do |t|
      t.string :name
      t.string :email
      t.belongs_to :target
      t.text :memo

      t.timestamps null: false
    end
    add_index "asset_persons", ["target_id", "email"], name: "asset_persons_email_index", unique: true

  end
end
