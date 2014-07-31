class AddRuleIdToRule < ActiveRecord::Migration
  def change
    add_column :rule, :from_rule_id, :integer
  end
end
