
class AssetDomainsController < ApplicationController
  before_action :set_target, only: [:index, :create, :show, :new, :edit, :update, :destroy, :reload]
  before_filter :require_user
  respond_to :html, :js
  protect_from_forgery :except => [:new, :edit, :reload]
  layout 'member', only: [:index]

  def index
    @domains = get_all

  end

  def new
    @domain ||= AssetDomain.new
  end

  def create
    domain = asset_domain_params[:domain]
    if domain
      memo = asset_domain_params[:memo]
      autoimport = (params[:autoimport] == 'on')
      begin
        @asset_domain = @target.asset_domains.find_or_create_by(target_id: @target.id, domain: domain, memo: memo, useradd:true)
        if autoimport
          ImportDomainAssetWorker.perform_async(@target.id, domain)
        end
      rescue ActiveRecord::RecordNotUnique => e
        @errmsg = '已经存在相同记录'
      rescue =>e
        @errmsg = e.to_s
      end

      @domains = get_all
    else
      @errmsg = '参数错误！'
    end

  end

  def edit
  end

  def update
    if @domain
      @domain[:useradd] = true
      if @domain.update(asset_domain_params)
        @domains = get_all
      else
        @errmsg = '更新失败！'
      end
    else
      @errmsg = '参数错误！'
    end
  end

  def destroy
    if @domain
      @domain.destroy
    else
      @errmsg = '未找到数据！'
    end
    @domains = get_all
  end

  def show
  end

  def reload
    @domains = get_all
  end

  private

    def asset_domain_params
      params.require(:asset_domain).permit(:domain, :memo)
    end

    def set_target
      @target = Target.find(params[:target_id]) rescue nil
      if @target.nil?
        flash[:alert] = "目标不存在！"
        return redirect_to targets_path
      end
      if params[:id]
        @domain = AssetDomain.find(params[:id]) rescue nil
      end

    end

  def get_all()
    @filterrific = initialize_filterrific(
        @target.asset_domains,
        params[:filterrific],
    ) or return nil
    @filterrific.find.paginate(page:params[:page], per_page:params[:per_page] || 20)
    #@target.asset_domains.paginate(:page => params[:page],
    #                             :per_page => params[:per_page] || 20).order('id DESC')

  end
end

