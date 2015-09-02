
class AssetEntrancesController < ApplicationController
  before_action :set_target, only: [:index, :create, :show, :new, :edit, :update, :destroy, :reload]
  before_filter :require_user
  respond_to :html, :js
  protect_from_forgery :except => [:new, :edit, :reload]
  layout 'member', only: [:index]

  def index
    @entrances = @target.asset_entrances.paginate(:page => params[:page],
                                                    :per_page => params[:per_page] || 20).order('id DESC')
  end

  def new
    @entrance ||= AssetEntrance.new
  end

  def create
    entrance_type = asset_entrance_params[:entrance_type]
    if entrance_type
      value = asset_entrance_params[:value]
      memo = asset_entrance_params[:memo]
      begin
        @asset_entrance = @target.asset_entrances.find_or_create_by(entrance_type: entrance_type, value: value){|entrance|
          entrance[:memo] = memo
        }
      rescue ActiveRecord::RecordNotUnique => e
        @errmsg = '已经存在相同记录'
      rescue =>e
        @errmsg = e.to_s
      end

      @entrances = @target.asset_entrances.paginate(:page => params[:page],
                                              :per_page => params[:per_page] || 20).order('id DESC')
    else
      @errmsg = '参数错误！'
    end

  end

  def edit
  end

  def update
    if @entrance
      if @entrance.update(asset_entrance_params)
        @entrances = @target.asset_entrances.paginate(:page => params[:page],
                                                  :per_page => params[:per_page] || 20).order('id DESC')
      else
        @errmsg = '更新失败！'
      end
    else
      @errmsg = '参数错误！'
    end
  end

  def destroy
    if @entrance
      @entrance.destroy
    else
      @errmsg = '未找到数据！'
    end
    @entrances = @target.asset_entrances.paginate(:page => params[:page],
                                              :per_page => params[:per_page] || 20).order('id DESC')
  end

  def show
  end

  def reload
    @entrances = @target.asset_entrances.paginate(:page => params[:page],
                                              :per_page => params[:per_page] || 20).order('id DESC')
  end

  private

    def asset_entrance_params
      params.require(:asset_entrance).permit(:entrance_type, :value, :memo)
    end

    def set_target
      @target = Target.find(params[:target_id]) rescue nil
      if @target.nil?
        flash[:alert] = "目标不存在！"
        return redirect_to targets_path
      end
      if params[:id]
        @entrance = AssetEntrance.find(params[:id]) rescue nil
      end

    end
end

