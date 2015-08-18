class CreateHosts < ActiveRecord::Migration
  def change
    create_table :asset_hosts do |t|
      t.string :host
      t.belongs_to :target
      t.text :memo

      t.timestamps null: false
    end
    add_index "asset_hosts", ["target_id", "host"], name: "asset_hosts_host_index", unique: true

  end
end
