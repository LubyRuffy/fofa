class CreatePersons < ActiveRecord::Migration
  def change
    create_table :asset_persons do |t|
      t.string :name
      t.string :email
      t.belongs_to :target
      t.text :memo

      t.timestamps null: false
    end
  end
end
