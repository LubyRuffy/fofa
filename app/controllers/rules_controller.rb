class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy, :save]
  #before_filter :require_user

  # GET /rules
  # GET /rules.json
  def index
    @rules = Rule.all
  end

  # GET /rules/1
  # GET /rules/1.json
  def show

  end

  # GET /rules/new
  def new
    @rule = Rule.new
    @rawrule = params['q']
    @rawrule = Base64.decode64(params['qbase64']) if params['qbase64'] &&  params['qbase64'].size>2
    @rawrule.force_encoding('utf-8').strip! if @rawrule
  end

  # GET /rules/1/edit
  def edit
    require_user

    unless @rule
      flash[:alert] = "规则不存在！"
      return redirect_to rules_path
    end

    unless @rule.user == current_user
      flash[:alert] = "只能管理自己的规则！"
      return redirect_to rules_path
    end
  end

  # POST /rules
  # POST /rules.json
  def create
    if current_user
      @rule = current_user.rules.new(rule_params)
    else
      @rule = Rule.new(rule_params)
    end

    respond_to do |format|
      if @rule.save
        format.html {
          @rawrule=@rule.rule
          @rule = Rule.new
          @notice= '规则提交成功，审核后将会显示在组件列表页面，感谢您的支持！'
          render :new
        }
        format.json { render :show, status: :created, location: @rule }
      else
        format.html { render :new }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rules/1
  # PATCH/PUT /rules/1.json
  def update
    require_user

    unless @rule
      flash[:alert] = "规则不存在！"
      return redirect_to rules_path
    end

    unless @rule.user == current_user
      flash[:alert] = "只能管理自己的规则！"
      return redirect_to rules_path
    end

    respond_to do |format|
      if @rule.update(rule_params)
        format.html { redirect_to @rule, notice: 'Rule was successfully updated.' }
        format.json { render :show, status: :ok, location: @rule }
      else
        format.html { render :edit }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    require_user

    unless @rule
      flash[:alert] = "规则不存在！"
      return redirect_to rules_path
    end

    unless @rule.user == current_user
      flash[:alert] = "只能管理自己的规则！"
      return redirect_to rules_path
    end

    @rule.destroy
    respond_to do |format|
      format.html { redirect_to rules_url, notice: 'Rule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #收藏
  def save
    require_user

    @ur = Userruleship.new(user:current_user, rule:@rule)
    respond_to do |format|
      if @ur.save
        format.html { redirect_to rules_url, notice: '收藏成功！' }
        format.json { head :no_content }
      else
        format.html { redirect_to rules_url, alert: '收藏失败！' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      @rule = Rule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rule_params
      params.require(:rule).permit(:product, :producturl, :rule)
    end
end
