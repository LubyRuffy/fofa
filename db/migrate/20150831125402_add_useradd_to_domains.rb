class AddUseraddToDomains < ActiveRecord::Migration
  def change
    add_column :asset_domains, :useradd, :boolean
    add_column :asset_hosts, :useradd, :boolean
    add_column :asset_ips, :useradd, :boolean
  end
end
