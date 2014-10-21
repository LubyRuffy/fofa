class AddFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :user, :sash_id, :integer
    add_column :user, :level, :integer, :default => 0
  end

  def self.down
    remove_column :user, :sash_id
    remove_column :user, :level
  end
end
