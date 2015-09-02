class AssetEntrance < ActiveRecord::Base
  self.table_name="asset_entrances"
  belongs_to :target

  acts_as_taggable
end
