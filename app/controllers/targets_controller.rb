require 'dumpasset'

class TargetsController < InheritedResources::Base
  include Lrlink
  before_action :set_target, only: [:show, :edit, :update, :destroy, :getdumpinfo, :adddumptask, :import_emails]
  before_filter :require_user
  layout 'member'

  def index
    @targets = current_user.targets.paginate(:page => params[:page],
                                                    :per_page => 20).order('id DESC')
  end

  def create
    @target = Target.new(target_params)

    respond_to do |format|
      if @target.save
        @target.usertargets.create(:user => current_user, :user_type => "owner")
        add_dump_task
        format.html { redirect_to targets_url, notice: '创建成功！' }
        format.json { render :show, status: :created, location: @target }
      else
        format.html { render :new }
        format.json { render json: @target.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @target.destroy
    respond_to do |format|
      format.html { redirect_to targets_url, notice: '删除成功！' }
      format.json { head :no_content }
    end
  end

  def show
    @show_toolbar = true
    @show_task = not_finished_dump_task?(@target.id)
  end

  def getdumpinfo
    key = target_redis_key(@target.id)

    if Sidekiq.redis {|redis| redis.exists(key) }
      msgs = Sidekiq.redis {|redis| redis.lrange(key, 0, -1) }
      render :json => {error:false, msgs:msgs, finished:msgs.include?('<<<finished>>>')}
    else
      render :json => {error:false, msgs:[], finished:true}
    end

  end

  def adddumptask
    need_add = add_dump_task
    render :json => {error:false, jobid:@target.id, need_add:need_add}
  end


  private

  def not_finished_dump_task?(taskid)
    Sidekiq.redis{|redis|
      key = target_redis_key(taskid)
      if redis.exists(key)
        msgs = redis.lrange(key, -1, -1)
        if !msgs.include?('<<<finished>>>')
          return true
        end
      end
    }
    return false
  end

  def add_dump_task
    Sidekiq.redis{|redis|
      need_add = !not_finished_dump_task?(@target.id)
      if need_add
        key = target_redis_key(@target.id)
        redis.del(key)
        redis.rpush(key, 'start dumping...')
        redis.expire(key, 60) #10秒超时
        DumpassetWorker.perform_async(@target.id, @target.website)
      end
    }
  end

    def target_params
      params.require(:target).permit(:name, :website, :memo, :tag_list)
    end

    def set_target
      @target = current_user.targets.find(params[:id]) rescue nil
      if @target.nil?
        flash[:alert] = "目标不存在！"
        return redirect_to targets_path
      end
    end
end

