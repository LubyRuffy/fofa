class AddDomainToPersons < ActiveRecord::Migration
  def change
    add_column :asset_persons, :domain, :string
  end
end
