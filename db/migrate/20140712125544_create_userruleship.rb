class CreateUserruleship < ActiveRecord::Migration
  def change
    create_table :userruleship do |t|
      t.integer :user_id
      t.integer :rule_id

      t.timestamps
    end
  end
end
