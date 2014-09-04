class MyController < ApplicationController
  before_filter :require_user
  layout "main"

  def index
    unless (current_user.key && current_user.key.size==32)
      require 'securerandom'
      key = SecureRandom.hex
      current_user.update_attribute(:key, key)
    end
  end

end
