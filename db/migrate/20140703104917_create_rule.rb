class CreateRule < ActiveRecord::Migration
  def change
    create_table :rule do |t|
      t.string :product
      t.string :producturl
      t.string :rule

      t.timestamps
    end
  end
end
