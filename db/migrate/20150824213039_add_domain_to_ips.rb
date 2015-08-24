class AddDomainToIps < ActiveRecord::Migration
  def change
    add_column :asset_ips, :domain, :string
    add_column :asset_ips, :ipnet, :string
  end
end
