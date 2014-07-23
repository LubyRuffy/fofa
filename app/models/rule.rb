class Rule < ActiveRecord::Base
  belongs_to :user

  has_many :subrules, class_name: "Rule"
  belongs_to :parentrule, class_name: "Rule", foreign_key: "from_rule_id"
end
