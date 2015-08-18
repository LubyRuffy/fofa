class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.string :name
      t.string :website
      t.text :memo

      t.timestamps null: false
    end
    add_index "targets", ["name"], name: "targets_name"

    create_table :users_targets do |t|
      t.belongs_to :user
      t.belongs_to :target
      t.string :user_type

      t.timestamps null: false
    end
    add_index "users_targets", ["target_id", "user_id"], name: "users_targets_index", unique: true

    create_table :asset_domains do |t|
      t.string :domain
      t.belongs_to :target
      t.text :memo

      t.timestamps null: false
    end
    add_index "asset_domains", ["target_id", "domain"], name: "asset_domains_target_index", unique: true

    create_table :asset_ips do |t|
      t.string :ip
      t.belongs_to :target
      t.text :memo

      t.timestamps null: false
    end
    add_index "asset_ips", ["target_id", "ip"], name: "asset_ips_ip_index", unique: true

  end
end
