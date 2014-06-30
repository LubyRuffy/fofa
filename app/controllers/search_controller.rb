# -*- encoding : utf-8 -*-

class SearchController < ApplicationController
  helper SearchHelper

  def index
    #@tbl_cnt = Subdomain.search_count 
    @site_cnt = Subdomain.count
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
    @query = Base64.decode64(params['qbase64']) if params['qbase64'] &&  params['qbase64'].size>2 
    @query_l = nil
    begin
      @query_l = SearchHelper::SphinxProcessor.parse(@query)
    rescue => e #Parslet::ParseFailed
      puts "QueryParser failed:"+e.inspect+e.backtrace.to_s
    end

    @results = nil
    begin
      if @query_l
        @mode = "extended"
        #@results = Subdomain.search Riddle::Query.escape(@query), :per_page => 10, :page => params['page']
        #@results = Subdomain.search @query_l, :index => 'idx1', :match_mode => :extended, :per_page => 10, :page => params['page'], :order => "lastupdatetime DESC"
        @results = ThinkingSphinx.search @query_l, :index => 'idx1', :match_mode => :extended, :per_page => 10, :page => params['page'], :order => "lastupdatetime DESC"
      else
        @mode = "normal"
        #@results = Subdomain.search Riddle::Query.escape(@query), :index => 'idx1', :per_page => 10, :page => params['page'], :order => "lastupdatetime DESC"
        @results = ThinkingSphinx.search Riddle::Query.escape(@query), :index => 'idx1', :per_page => 10, :page => params['page'], :order => "lastupdatetime DESC"
      end
      @tags = {}
      if @results
        @results.each {|x|
          @tags[x.hosthash] = Tag.find_all_by_hosthash x.hosthash
        }
      end
    rescue ThinkingSphinx::SphinxError => e
      @error = e.to_s
    end
    
    #require 'pp'
    #pp @results
  end
end
