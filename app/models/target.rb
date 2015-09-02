class Target < ActiveRecord::Base
  acts_as_taggable

  has_many :usertargets
  has_many :users, through: :usertargets
  has_many :asset_domains, dependent: :delete_all
  has_many :asset_ips, dependent: :delete_all
  has_many :asset_hosts, dependent: :delete_all
  has_many :asset_persons, dependent: :delete_all
  has_many :asset_entrances, dependent: :delete_all
  has_many :sensitives
end
