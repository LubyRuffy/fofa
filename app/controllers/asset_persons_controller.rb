
class AssetPersonsController < ApplicationController
  before_action :set_target, only: [:index, :create, :show, :new, :edit, :update, :destroy, :get_all_json]
  before_filter :require_user
  respond_to :html, :js
  protect_from_forgery :except => [:new, :edit, :reload]
  layout 'member', only: [:index]

  def index
    @persons = @target.asset_persons.paginate(:page => params[:page],
                                                    :per_page => params[:per_page] || 20).order('id DESC')
  end

  def new
    @person ||= AssetPerson.new
  end

  def create
    @name = asset_person_params[:name]
    if @name
      @alias = asset_person_params[:alias]
      @email = asset_person_params[:email]
      @otheremails = asset_person_params[:otheremails]
      @memo = asset_person_params[:memo]
      begin
        @asset_person = @target.asset_persons.find_or_create_by(target_id: @target.id, name: @name, alias:@alias, email:@email, otheremails:@otheremails, memo: @memo, useradd:true)
      rescue ActiveRecord::RecordNotUnique => e
        @errmsg = '已经存在相同记录'
      rescue =>e
        @errmsg = e.to_s
      end

      @persons = @target.asset_persons.paginate(:page => params[:page],
                                              :per_page => params[:per_page] || 20).order('id DESC')
    else
      @errmsg = '参数错误！'
    end

  end

  def edit

  end

  def update
    if @person
      @person[:useradd] = true
      if @person.update(asset_person_params)
        @persons = @target.asset_persons.paginate(:page => params[:page],
                                                  :per_page => params[:per_page] || 20).order('id DESC')
      else
        @errmsg = '更新失败！'
      end
    else
      @errmsg = '参数错误！'
    end
  end

  def destroy
    if @person
      @person.destroy
    else
      @errmsg = '未找到数据！'
    end
    @persons = @target.asset_persons.paginate(:page => params[:page],
                                              :per_page => params[:per_page] || 20).order('id DESC')
  end

  def show
  end

  def get_all_json
    persons_g = @target.asset_persons.select('id,name,email,domain').group_by(&:domain).sort_by{|k,v| -v.size}
    data = persons_g.map{|domain,persons|
      {
          name: "#{domain} <div class='tree-actions'><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{persons.size}</span>",
          type: 'folder',
          additionalParameters: { id: domain },
          data: persons.map{|person|
            { name: "#{view_context.link_to view_context.raw("#{person.name}(#{person.email})"), edit_target_asset_person_path(@target, person), remote: true}<div class='tree-actions'>#{view_context.link_to view_context.raw("<i class='fa fa-trash-o'></i>"), target_asset_person_path(@target, person), remote: true, method: :delete, data: { confirm: '确定要删除吗?' }}", type: 'item', additionalParameters: { id: person.id } }
          }
      }
    }
    render :json => {error:false, data:data, size:persons_g.inject(0) {|sum, arr| sum + arr[1].size } }
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  private

    def asset_person_params
      params.require(:asset_person).permit(:name, :email, :memo, :alias, :otheremails, :tag_list)
    end

    def set_target
      @target = Target.find(params[:target_id]) rescue nil
      if @target.nil?
        flash[:alert] = "目标不存在！"
        return redirect_to targets_path
      end
      if params[:id]
        @person = AssetPerson.find(params[:id]) rescue nil
      end

    end
end

