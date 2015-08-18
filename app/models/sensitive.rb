
require 'elasticsearch/model'

class Sensitive < ActiveRecord::Base
  belongs_to :user

  #index_name    "fofa-sensitive"
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
end