class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy, :save]
  before_filter :require_user
  layout 'member'

  # GET /categories
  # GET /categories.json
  def index
    @categories = current_user.categories.paginate(:page => params[:page],
                                         :per_page => 50).order('id DESC')
  end

  # GET /categories/1
  # GET /categories/1.json
  def show

  end

  # GET /categories/new
  def new
    @category = current_user.categories.new
    @rawcategory = params['title']
    @rawcategory = Base64.decode64(params['titlebase64']) if params['titlebase64'] &&  params['titlebase64'].size>2
    @rawcategory.force_encoding('utf-8').strip! if @rawcategory
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = current_user.categories.build(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_url, notice: '创建成功！' }
        format.json { render :show, status: :created, location: categories_url }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update

    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to edit_category_path(@category), notice: '更新成功！' }
        format.json { render :show, status: :ok, location: edit_category_path(@category) }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.rules.delete_all
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: '删除成功！' }
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
        format.html { redirect_to categories_url, notice: '收藏成功！' }
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
    def set_category
      @category = current_user.categories.find(params[:id]) rescue nil
      if @category.nil?
        flash[:alert] = "规则组不存在！"
        return redirect_to categories_path
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:title, :rule_ids=>[])
    end
end
