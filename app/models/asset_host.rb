class AssetHost < ActiveRecord::Base
  self.table_name="asset_hosts"
  belongs_to :target

  acts_as_taggable
end
