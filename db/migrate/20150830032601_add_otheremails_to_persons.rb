class AddOtheremailsToPersons < ActiveRecord::Migration
  def change
    add_column :asset_persons, :otheremails, :text
    add_column :asset_persons, :alias, :text
    add_index "asset_persons", ["target_id", "name"], name: "asset_persons_name_index", unique: true
  end
end
