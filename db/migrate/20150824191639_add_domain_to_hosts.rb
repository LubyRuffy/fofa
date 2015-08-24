class AddDomainToHosts < ActiveRecord::Migration
  def change
    add_column :asset_hosts, :domain, :string
  end
end
