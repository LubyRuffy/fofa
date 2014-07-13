class Rule < ActiveRecord::Base
  has_many :userruleships
  has_many :saveusers, :class_name => "User", :through => :userruleships, :foreign_key => "rule_id"
  belongs_to :user
end
