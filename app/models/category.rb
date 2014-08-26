class Category < ActiveRecord::Base
  belongs_to :user

  has_and_belongs_to_many :rules

  scope :published, -> { where(published: true) }
end
