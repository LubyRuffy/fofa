# -*- encoding : utf-8 -*-
require "sidekiq"

class SearchController < ApplicationController
  include SearchHelper
  include ApiHelper

  def index
    #@tbl_cnt = Subdomain.search_count
    #@last = Subdomain.last
    #@show_ws_link = true
  end
  
  def get_web_cnt
    #@tbl_cnt = Subdomain.search_count
    render :text => Subdomain.es_size
  end

  def get_hosts_by_ip
    @error, @mode, @results, @tags = search("ip=\"#{params['ip']}.\"")
    respond_to do |format|
      format.html {render '/search/gethostsbyip', :layout => false}
      format.json {render :json => @results}
    end
  end

  def remove_black_ips
    Sidekiq.redis{|redis|
      redis.srem("black_ips", params['ip'])
    }
    respond_to do |format|
      format.html {render :text => "已经移除黑名单！"}
      format.json {render :json => {:status=>"ok"}}
    end
  end

  def get_host_content
  	unless params['host'].downcase.include?('qihoo.net')
    	render :json => {'host'=>Subdomain.es_get(params['host'])['_source']}
    else
      render :json => {'host'=>''}
    end
  end

  def result
    check_badge
    @query = params['q']
    @qbase64=params['qbase64']
    @page = params['page'] || 1
    @current_admin_user = current_admin_user
    @query = Base64.decode64(params['qbase64']) if params['qbase64'] &&  params['qbase64'].size>2
    #puts @query.encoding
    #@query.force_encoding('utf-8')
    #render :text => @query
    @error, @mode, @results, @tags, @es_query_string = search(@query, 10, @page, true)
    if @page && @page.to_i>10 && !current_user
      @error = "未登录状态只能查看100条记录，登录后可查看1000条记录！";
    end
    #require 'pp'
    #pp @results
  end

  def checkapp
    @host = params['host']
    #@post = request.post?
    t1 = Time.now.to_f
    @app = check_app(@host, params['all']) if @host #&& @post
    @time_delta = Time.now.to_f - t1
  end

  def refresh
    @host = params['host']
    RealtimeprocessWorker.perform_async(@host, true)
    render :text => "强制刷新成功！"
  end

end
