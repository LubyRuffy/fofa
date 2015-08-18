class CreateSensitives < ActiveRecord::Migration
  def change
    create_table :sensitives do |t|
      t.string :reference
      t.text :content
      t.belongs_to :user
      t.text :memo

      t.timestamps null: false
    end

  end
end
