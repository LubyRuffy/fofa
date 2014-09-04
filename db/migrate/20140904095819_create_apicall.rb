class CreateApicall < ActiveRecord::Migration
  def change
    create_table :apicall do |t|
      t.integer :user_id
      t.string :query
      t.string :action
      t.string :ip
      t.timestamps
    end
  end
end
