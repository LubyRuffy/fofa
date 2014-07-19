class MyController < ApplicationController
  before_filter :require_user
  before_action :set_rule, only: [:unsave]
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

  #收藏
  def unsave
    @rule = Rule.find(params[:id])

    @ur = current_user.saverules.find(@rule)
    @ur.destroy
    respond_to do |format|
      format.html { redirect_to unsave_url, notice: '取消收藏' }
      format.json { head :no_content }
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_rule
    @rule = Rule.find(params[:id]) rescue nil
    unless @rule
      flash[:alert] = "规则不存在！"
      return redirect_to my_path
    end
  end
end
