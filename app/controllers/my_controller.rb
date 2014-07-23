class MyController < ApplicationController
  before_filter :require_user
  layout "main"

  def index
  end

end
