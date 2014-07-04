# -*- encoding : utf-8 -*-
require "resque"
require "#{Rails.root}/app/jobs/url_worker.rb"

class SearchController < ApplicationController
  helper SearchHelper
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

  def get_host_content
    render :json => {'host'=>Subdomain.find_by_host(params['host']).body}
  end

  def result
    @query = params['q']
    @qbase64=params['qbase64']
    @query = Base64.decode64(params['qbase64']) if params['qbase64'] &&  params['qbase64'].size>2
    @error, @mode, @results, @tags = search(@query)
    
    #require 'pp'
    #pp @results
  end
end
