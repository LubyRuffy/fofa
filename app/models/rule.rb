class Rule < ActiveRecord::Base
  self.table_name="rule"
  belongs_to :user

  has_many :subrules, class_name: "Rule"
  belongs_to :parentrule, class_name: "Rule", foreign_key: "from_rule_id"

  has_and_belongs_to_many :categories

  scope :published, -> { where(published: true) }
end
