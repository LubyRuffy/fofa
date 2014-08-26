class Productgroup < ActiveRecord::Base
  belongs_to :category
  belongs_to :rule
end
