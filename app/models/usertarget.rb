class Usertarget < ActiveRecord::Base
  self.table_name = 'users_targets'
  belongs_to :user
  belongs_to :target
end
