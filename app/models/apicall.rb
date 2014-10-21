class Apicall < ActiveRecord::Base
  self.table_name="apicall"
  belongs_to :user
end
