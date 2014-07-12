class Userruleship < ActiveRecord::Base
  belongs_to :user
  belongs_to :rule
end
