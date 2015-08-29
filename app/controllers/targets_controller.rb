require 'dumpasset'

class TargetsController < InheritedResources::Base
  include Lrlink
  before_action :set_target, only: [:show, :edit, :update, :destroy, :getdumpinfo, :adddumptask, :add_domain, :add_host, :get_domains_json, :get_hosts_json, :get_ips_json, :get_persons_json]
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

  def add_domain
    domain = params[:domain]
    autoimport = (params[:autoimport] == 'true')
    ad = @target.asset_domains.find_or_create_by(target_id: @target.id, domain: domain)

    if autoimport
      ImportDomainAssetWorker.perform_async(@target.id, domain)
    end

    render :json => {error:false, domain_id:ad[:id]}
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  def add_host
    host = params[:host]
    domain_info = get_domain_info_by_host(host)
    if !domain_info
      render :json => {error:true, errmsg:"invalid host!"}
    else
      domain = domain_info.domain+'.'+domain_info.public_suffix
      ad = @target.asset_hosts.find_or_create_by(target_id: @target.id, host: host, domain:domain)
      render :json => {error:false, domain_id:ad[:id]}
    end

  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  def get_domains_json
    @domains = @target.asset_domains.select('id, domain, created_at')
    render :json => {error:false, domains:@domains}
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  def get_hosts_json
    hosts_g = @target.asset_hosts.select('id, host, domain').group_by(&:domain).sort_by{|k,v| -v.size}
    data = hosts_g.map{|d,hosts|
      {
          name: "#{d} <div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{hosts.size}</span>",
          type: 'folder',
          additionalParameters: { id: d },
          data: hosts.map{|h|
            { name: h.host+"<div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div>", type: 'item', additionalParameters: { id: h.host } }
          }
      }
    }
    render :json => {error:false, data:data, size:hosts_g.inject(0) {|sum, arr| sum + arr[1].size } }
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  def get_ips_json
    ips_g = @target.asset_ips.select('ip,ipnet').group_by(&:ipnet).sort_by{|k,v| -v.size}
    data = ips_g.map{|ipnet,ips|
      {
          name: "#{ipnet} <div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{ips.size}</span>",
          type: 'folder',
          additionalParameters: { id: ipnet },
          data: ips.map{|ip|
            { name: ip.ip+"<div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div>", type: 'item', additionalParameters: { id: ip.ip } }
          }
      }
    }
    render :json => {error:false, data:data, size:ips_g.inject(0) {|sum, arr| sum + arr[1].size } }
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
  end

  def get_persons_json
    persons_g = @target.asset_persons.select('name,email,domain').group_by(&:domain).sort_by{|k,v| -v.size}
    data = persons_g.map{|domain,persons|
      {
          name: "#{domain} <div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div> <span class='badge bg-default'>#{persons.size}</span>",
          type: 'folder',
          additionalParameters: { id: domain },
          data: persons.map{|person|
            { name: "#{person.name}(#{person.email})<div class='tree-actions'><i class='fa fa-plus'></i><i class='fa fa-trash-o'></i><i class='fa fa-refresh'></i></div>", type: 'item', additionalParameters: { id: person.id } }
          }
      }
    }
    render :json => {error:false, data:data, size:persons_g.inject(0) {|sum, arr| sum + arr[1].size } }
  rescue => e
    render :json => {error:true, errmsg:e.to_s}
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

