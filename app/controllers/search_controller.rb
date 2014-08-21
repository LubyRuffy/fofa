# -*- encoding : utf-8 -*-
require "sidekiq"
require "#{Rails.root}/app/workers/url_worker.rb"

class SearchController < ApplicationController
  include SearchHelper
  include ApiHelper

  def index
    #@tbl_cnt = Subdomain.search_count 
    @site_cnt = Subdomain.count
    @last = Subdomain.last
    @show_ws_link = true
  end
  
  def get_web_cnt
    #@tbl_cnt = Subdomain.search_count 
    render :text => Subdomain.count
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
    render :json => {'host'=>Subdomain.find_by_host(params['host']).body}
  end

  def result
    @query = params['q']
    @qbase64=params['qbase64']
    @query = Base64.decode64(params['qbase64']) if params['qbase64'] &&  params['qbase64'].size>2
    #puts @query.encoding
    #@query.force_encoding('utf-8')
    #render :text => @query
    @error, @mode, @results, @tags = search(@query)
    
    #require 'pp'
    #pp @results
  end

  def checkapp
    @host = params['host']
    @app = check_app(@host, params['all']) if @host
  end

end
