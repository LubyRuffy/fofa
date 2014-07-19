class MyController < ApplicationController
  before_filter :require_user
  before_action :set_rule, only: [:unsave, :ruledestroy]
  layout "main"

  def index
  end

  def rules
    @rules = current_user.rules.paginate(:page => params[:page],
                                         :per_page => 10).order('id DESC')
  end

  def saverules
    @rules = current_user.saverules.paginate(:page => params[:page],
                                         :per_page => 10).order('id DESC')
  end

  #取消收藏
  def unsave
    current_user.saverules.delete(@rule)
    respond_to do |format|
      format.html { redirect_to my_saverules_path, notice: '已取消收藏！' }
      format.json { head :no_content }
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def ruledestroy
    check_user_rule!
    @rule.destroy
    respond_to do |format|
      format.html { redirect_to my_rules_path, notice: '规则已经删除！' }
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

  def check_user_rule!
    unless @rule.user == current_user
      flash[:alert] = "只能管理自己的规则！"
      return redirect_to rules_path
    end
  end
end
