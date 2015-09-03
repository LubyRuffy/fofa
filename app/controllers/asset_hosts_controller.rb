
class AssetHostsController < ApplicationController
  include Lrlink

  before_action :set_target, only: [:index, :create, :show, :new, :edit, :update, :destroy, :reload, :get_all_json]
  before_filter :require_user
  respond_to :html, :js
  protect_from_forgery :except => [:new, :edit, :reload]
  layout 'member', only: [:index]

  def index
    @hosts = get_all(true)
  end

  def new
    @host ||= AssetHost.new
  end

  def create
    host = asset_host_params[:host]
    if host
      domain_info = get_domain_info_by_host(host)
      if !domain_info
        @errmsg = '域名格式错误！'
      else
        domain = domain_info.domain+'.'+domain_info.public_suffix
        memo = asset_host_params[:memo]
        autoimport = (params[:autoimport] == 'on')
        begin
          @asset_host = @target.asset_hosts.find_or_create_by(target_id: @target.id, host: host, domain:domain, memo: memo, useradd:true)
          if autoimport
            ImportHostAssetWorker.perform_async(@target.id, host)
          end
        rescue ActiveRecord::RecordNotUnique => e
          @errmsg = '已经存在相同记录'
        rescue =>e
          @errmsg = e.to_s
        end

        @hosts = get_all
      end
    else
      @errmsg = '参数错误！'
    end

  end

  def edit
  end

  def update
    if @host
      domain_info = get_domain_info_by_host(@host.host)
      if !domain_info
        @errmsg = '域名格式错误！'
      else
        @host[:useradd] = true
        @host[:domain] = domain_info.domain+'.'+domain_info.public_suffix
        if @host.update(asset_host_params)
          @hosts = get_all
        else
          @errmsg = '更新失败！'
        end
      end
    else
      @errmsg = '参数错误！'
    end
  end

  def destroy
    if @host
      @host.destroy
    else
      @errmsg = '未找到数据！'
    end
    @hosts = get_all
  end

  def show
  end

  def reload
    @hosts = get_all(params[:tree])
  end

  def get_all_json
    hosts_g = @target.asset_hosts.select('id, host, domain').group_by(&:domain).sort_by{|k,v| -v.size}
    data = hosts_g.map{|d,hosts|
      {
          name: "#{d} <div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{hosts.size}</span>",
          type: 'folder',
          additionalParameters: { id: d },
          data: hosts.map{|h|
            { name: "#{view_context.link_to h.host, edit_target_asset_host_path(@target, h), remote: true}<div class='tree-actions'>#{view_context.link_to view_context.raw("<i class='fa fa-trash-o'></i>"), target_asset_host_path(@target, h), remote: true, method: :delete, data: { confirm: '确定要删除吗?' }}",
              type: 'item', additionalParameters: { id: h.id } }
          }
      }
    }
    render :json => {error:false, data:data, size:hosts_g.inject(0) {|sum, arr| sum + arr[1].size } }
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  private

    def asset_host_params
      params.require(:asset_host).permit(:host, :memo)
    end

    def set_target
      @target = Target.find(params[:target_id]) rescue nil
      if @target.nil?
        flash[:alert] = "目标不存在！"
        return redirect_to targets_path
      end
      if params[:id]
        @host = AssetHost.find(params[:id]) rescue nil
      end

    end

  def get_all(tree=false)
    @filterrific = initialize_filterrific(
        @target.asset_hosts,
        params[:filterrific],
    ) or return nil
    results = @filterrific.find.paginate(page:params[:page], per_page:params[:per_page] || 20)
    #@target.asset_hosts.paginate(:page => params[:page],
    #                             :per_page => params[:per_page] || 20).order('id DESC')

    if tree
      hosts_g = results.select('id, host, domain').group_by(&:domain).sort_by{|k,v| -v.size}
      @treedata = hosts_g.map{|d,hosts|
        {
            name: "#{d} <div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{hosts.size}</span>",
            type: 'folder',
            additionalParameters: { id: d },
            data: hosts.map{|h|
              { name: "#{view_context.link_to h.host, edit_target_asset_host_path(@target, h), remote: true}<div class='tree-actions'>#{view_context.link_to view_context.raw("<i class='fa fa-trash-o'></i>"), target_asset_host_path(@target, h), remote: true, method: :delete, data: { confirm: '确定要删除吗?' }}",
                type: 'item', additionalParameters: { id: h.id } }
            }
        }
      }
      @host_size = hosts_g.inject(0) {|sum, arr| sum + arr[1].size }
    end

    results
  end
end

