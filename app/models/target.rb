class Target < ActiveRecord::Base
  has_many :usertargets
  has_many :users, through: :usertargets
end
