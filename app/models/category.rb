class Category < ActiveRecord::Base
  belongs_to :user

  has_and_belongs_to_many :rules

  scope :published, -> { where(published: true) }


  def get_chart(rules_data)
    cat.rules.map{|r| rules_data.select{|d| d.id==r.id} }
    #self.find_by_sql("SELECT r.product,c.value FROM `rule` r, `category_rule` ,charts c WHERE `category_rule`.`category_id` = #{self.id} and `r`.`id` = `category_rule`.`rule_id` and `r`.`id` = `c`.`rule_id` ")
  end
end
