class AssetIp < ActiveRecord::Base
  self.table_name="asset_ips"
  belongs_to :target
end
