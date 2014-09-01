class CreateCharts < ActiveRecord::Migration
  def change
    create_table :charts do |t|
      t.references :rule
      t.integer :value
      t.date :writedate

      t.timestamps
    end

    add_index "charts", ["writedate", "rule_id"], name: "index_charts_on_writedate_rule", unique: true
  end
end
