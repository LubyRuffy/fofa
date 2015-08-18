class Target < ActiveRecord::Base
  has_many :usertargets
  has_many :users, through: :usertargets
  has_many :asset_domains
  has_many :asset_ips
  has_many :asset_hosts
  has_many :sensitives
end
