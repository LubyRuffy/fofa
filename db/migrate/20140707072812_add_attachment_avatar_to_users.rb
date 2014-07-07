class AddAttachmentAvatarToUsers < ActiveRecord::Migration
  def self.up
    change_table :user do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :user, :avatar
  end
end
