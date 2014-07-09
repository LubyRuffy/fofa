module ApiHelper
  def search(query, page_count=10)
    @query = query
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
        @results = ThinkingSphinx.search @query_l, :index => 'idx1', :match_mode => :extended, :per_page => page_count, :page => params['page'], :order => "lastupdatetime DESC"
      else
        @mode = "normal"
        #@results = Subdomain.search Riddle::Query.escape(@query), :index => 'idx1', :per_page => 10, :page => params['page'], :order => "lastupdatetime DESC"
        @results = ThinkingSphinx.search Riddle::Query.escape(@query), :index => 'idx1', :per_page => page_count, :page => params['page'], :order => "lastupdatetime DESC"
      end
      @tags = {}
      if @results
        @results.each {|x|
          @tags[x.hosthash] = Tag.find_by_hosthash x.hosthash
          @error, @msg = Userhost.add_user_host(x.host, '127.0.0.2')
          puts "error: #{@msg}" if @error
        }
      end
    rescue ThinkingSphinx::SphinxError => e
      @error = e.to_s
    end
    [@error, @mode, @results, @tags]
  end
end
