class AddPublishedToRule < ActiveRecord::Migration
  def change
    add_column :rule, :published, :bool
  end
end
