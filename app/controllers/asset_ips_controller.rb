
class AssetIpsController < ApplicationController
  include Lrlink

  before_action :set_target, only: [:index, :create, :show, :new, :edit, :update, :destroy, :reload, :get_all_json]
  before_filter :require_user
  respond_to :html, :js
  protect_from_forgery :except => [:new, :edit, :reload]
  layout 'member', only: [:index]

  def index
    @ips = get_all(true)
  end

  def new
    @ip ||= AssetIp.new
  end

  def create
    ip = asset_ip_params[:ip]
    if ip && ip.include?('.')
      memo = asset_ip_params[:memo]
      domain = asset_ip_params[:domain]
      begin
        ipnet = ip.split('.')[0..2].join('.')+'.0/24'
        @asset_ip = @target.asset_ips.find_or_create_by(target_id: @target.id, ip: ip, ipnet: ipnet, domain:domain, memo: memo, useradd:true)
      rescue ActiveRecord::RecordNotUnique => e
        @errmsg = '已经存在相同记录'
      rescue =>e
        @errmsg = e.to_s
      end

      @ips = get_all
    else
      @errmsg = '参数错误！'
    end

  end

  def edit
  end

  def update
    if @ip
      @ip[:useradd] = true
      @ip[:ipnet] = ip.split('.')[0..2].join('.')+'.0/24'
      if @ip.update(asset_ip_params)
        @ips = get_all
      else
        @errmsg = '更新失败！'
      end
    else
      @errmsg = '参数错误！'
    end
  end

  def destroy
    if @ip
      @ip.destroy
    else
      @errmsg = '未找到数据！'
    end
    @ips = get_all
  end

  def show
  end

  def reload
    @ips = get_all(true)
  end

  def get_all_json
    ips_g = @target.asset_ips.select('id, ip, ipnet').group_by(&:ipnet).sort_by{|k,v| -v.size}
    data = ips_g.map{|d,ips|
      {
          name: "#{d} <div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{ips.size}</span>",
          type: 'folder',
          additionalParameters: { id: d },
          data: ips.map{|h|
            { name: "#{view_context.link_to h.ip, edit_target_asset_ip_path(@target, h), remote: true}<div class='tree-actions'>#{view_context.link_to view_context.raw("<i class='fa fa-trash-o'></i>"), target_asset_ip_path(@target, h), remote: true, method: :delete, data: { confirm: '确定要删除吗?' }}",
              type: 'item', additionalParameters: { id: h.id } }
          }
      }
    }
    render :json => {error:false, data:data, size:ips_g.inject(0) {|sum, arr| sum + arr[1].size } }
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  private

    def asset_ip_params
      params.require(:asset_ip).permit(:ip, :memo)
    end

    def set_target
      @target = Target.find(params[:target_id]) rescue nil
      if @target.nil?
        flash[:alert] = "目标不存在！"
        return redirect_to targets_path
      end
      if params[:id]
        @ip = AssetIp.find(params[:id]) rescue nil
      end

    end

  def get_all(tree=false)
    @filterrific = initialize_filterrific(
        @target.asset_ips,
        params[:filterrific],
    ) or return nil
    results = @filterrific.find.paginate(page:params[:page], per_page:params[:per_page] || 20)
    #@target.asset_hosts.paginate(:page => params[:page],
    #                             :per_page => params[:per_page] || 20).order('id DESC')

    if tree
      ips_g = results.select('id, ip, ipnet').group_by(&:ipnet).sort_by{|k,v| -v.size}
      @treedata = ips_g.map{|d,ips|
        {
            name: "#{d} <div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{ips.size}</span>",
            type: 'folder',
            additionalParameters: { id: d },
            data: ips.map{|h|
              { name: "#{view_context.link_to h.ip, edit_target_asset_ip_path(@target, h), remote: true}<div class='tree-actions'>#{view_context.link_to view_context.raw("<i class='fa fa-trash-o'></i>"), target_asset_ip_path(@target, h), remote: true, method: :delete, data: { confirm: '确定要删除吗?' }}",
                type: 'item', additionalParameters: { id: h.id } }
            }
        }
      }
      @ip_size = ips_g.inject(0) {|sum, arr| sum + arr[1].size }
    end

    results
  end
end

