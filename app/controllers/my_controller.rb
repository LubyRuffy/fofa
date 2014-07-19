class MyController < ApplicationController
  before_filter :require_user
  layout "main"

  def index
  end

  def rules
    @rules = current_user.rules.paginate :page => params[:page],
                                         :per_page => 10
  end

  def saverules
    @rules = current_user.saverules.paginate :page => params[:page],
                                         :per_page => 10
  end
end
