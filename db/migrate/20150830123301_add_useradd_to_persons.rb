class AddUseraddToPersons < ActiveRecord::Migration
  def change
    add_column :asset_persons, :useradd, :boolean
  end
end
