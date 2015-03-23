# -*- encoding : utf-8 -*-
require "sidekiq"
require "#{Rails.root}/app/workers/url_worker.rb"

class SearchController < ApplicationController
  include SearchHelper
  include ApiHelper

  def index
    #@tbl_cnt = Subdomain.search_count
    @last = Subdomain.last
    #@show_ws_link = true
  end
  
  def get_web_cnt
    #@tbl_cnt = Subdomain.search_count
    render :text => get_table_cnt('subdomain') #Subdomain.count
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
    	render :json => {'host'=>Subdomain.find_by_host(params['host']).body}
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
    @error, @mode, @results, @tags = search(@query, 10, @page)
    if @page && @page.to_i>10 && !current_user
      @error = "未登录状态只能查看100条记录，登录后可查看1000条记录！";
    end
    #require 'pp'
    #pp @results
  end

  def checkapp
    @host = params['host']
    #@post = request.post?
    @app = check_app(@host, params['all']) if @host #&& @post
  end

  def refresh
    @host = params['host']
    Sidekiq::Client.enqueue_to("realtime_process_url", Processor, @host, true)
    render :text => "强制刷新成功！"
  end

end
