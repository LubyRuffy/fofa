class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy, :save]
  before_filter :require_user
  layout 'member'

  # GET /rules
  # GET /rules.json
  def index
    @rules = current_user.rules.paginate(:page => params[:page],
                                         :per_page => 50).order('id DESC')
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
        format.html { redirect_to rules_url, notice: '创建成功！' }
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

    respond_to do |format|
      if @rule.update(rule_params)
        format.html { redirect_to @rule, notice: '更新成功！' }
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

    @rule.destroy
    respond_to do |format|
      format.html { redirect_to rules_url, notice: '删除成功！' }
      format.json { head :no_content }
    end
  end

  #收藏
  def save
    new_rule = Rule.new
    new_rule.user = current_user
    new_rule.parentrule = @rule
    new_rule.product = @rule.product
    new_rule.producturl = @rule.producturl
    new_rule.rule = @rule.rule

    respond_to do |format|
      if new_rule.save
        format.html { redirect_to rules_url, notice: '收藏成功！' }
        format.json { head :no_content }
      else
        format.html { redirect_to rules_url, alert: '收藏失败！' }
        format.json { head :no_content }
      end
    end
  rescue  ActiveRecord::RecordNotUnique => e
    respond_to do |format|
        format.html { redirect_to rules_url, alert: '收藏失败：之前已经收藏！' }
        format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      if action_name == 'save'
        @rule = Rule.find(params[:id]) rescue nil
      else
        @rule = current_user.rules.find(params[:id]) rescue nil
      end
      if @rule.nil?
        flash[:alert] = "规则不存在！"
        return redirect_to rules_path
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rule_params
      params.require(:rule).permit(:product, :producturl, :rule, :category_ids=>[])
    end

end
