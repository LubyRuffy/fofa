class AssetDomain < ActiveRecord::Base
  self.table_name="asset_domains"
  belongs_to :target
end
