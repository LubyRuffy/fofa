class CreateAssetEntrance < ActiveRecord::Migration
  def change
    create_table :asset_entrances do |t|
      t.references :target
      t.string :entrance_type
      t.string :value
      t.text :memo
    end
    add_index "asset_entrances", ["target_id", "entrance_type", "value"], name: "asset_entrances_type_value_index", unique: true
  end
end
