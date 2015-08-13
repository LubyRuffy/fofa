require 'sidekiq'

class LabController < ApplicationController
  include ApiHelper

  def ips
    @domain = params['domain']
    maxsize = 1000
    maxsize = 10000 if current_user
    @ips = get_ips_of_domain_(@domain, maxsize)
  end

  def addtask
    @action = params['taskaction']
    unless @action
      render :json => {error:true, errormsg:'未知操作！' }
      return
    end
    @domain = params['domain']
    unless @domain && @domain.size>1
      render :json => {error:true, errormsg:'请输入域名！' }
      return
    end

    if @action.downcase=='alldomains' || @action.downcase=='domains' || @action.downcase=='alldomainsfrom' || @action.downcase=='gethosts' || @action.downcase=='getips'
      require 'securerandom'

      @jobid = SecureRandom.hex
      maxsize = 200
      maxsize = 1000 if current_user
      Uitask.perform_async( @jobid, @action, @domain, maxsize)
      render :json => {error:false, errormsg:'', jobId: @jobid}
      return
    else
      render :json => {error:true, errormsg:'未知操作！'}
    end
  end

  def gettask
    jobId = params['jobId']
    key = "task:#{jobId}"
    msgs = Sidekiq.redis {|redis| redis.lrange(key, 0, -1) }
    render :json => {error:false, msgs:msgs, finished:msgs.include?('<<<finished>>>')}
  end

  def alldomains
    @domain = params['domain']
  end

  def target
    @domain = params['domain']
  end

  def domains
    maxsize = 1000
    maxsize = 10000 if current_user
    @ips = get_ips_of_domain(@domain, maxsize)
    if ips
      all_ips = []
      ips.each do |net|
        ipnet,hosts,ips,netipcnt = net
        all_ips += ips.split(',')
      end

      @sphinxql_sql = ""
      if all_ips.size>0
        @sphinxql_sql = "(@ip \"#{all_ips.join('" | "')}\") @host -#{@domain}"
      end
      @results = search_sphinxql(@sphinxql_sql)

      b = @results.map{|r| r.domain}.inject(Hash.new(0)) {|h,i| h[i] += 1; h }
      @domains = b.to_a.sort_by{|r| -r[1].to_i}
    end
  end

  private
  def get_ips_of_domain_(domain, maxsize=1000)
    if domain
      key = 'domain_net:'+domain.downcase
      @ips = Sidekiq.redis{|redis| redis.get(key) }
      if @ips
        @ips = JSON.parse(@ips)
      else
        @ips = Subdomain.get_ips_of_domain(domain, maxsize)
        Sidekiq.redis{|redis|
          redis.set(key, @ips.to_json)
          redis.expire(key, 60*60*24)
        }
      end
      return @ips
    end
    nil
  end
end
