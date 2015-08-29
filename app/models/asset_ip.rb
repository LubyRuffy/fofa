class AssetIp < ActiveRecord::Base
  self.table_name="asset_ips"
  belongs_to :target

  acts_as_taggable
end
