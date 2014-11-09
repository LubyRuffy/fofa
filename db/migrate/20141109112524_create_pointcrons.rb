class CreatePointcrons < ActiveRecord::Migration
  def change
    create_table :pointcrons do |t|
      t.integer :user_id
      t.string :category
      t.integer :point
      t.timestamps
    end
  end
end
