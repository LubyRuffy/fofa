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
      options = {:index => 'idx1',:sql => { :select => 'id,ip,title,header,host,hosthash,lastupdatetime'},:per_page => page_count,:page => params['page'],:order => "lastupdatetime DESC"}#:retry_stale => 2,
      if @query_l
        @mode = "extended"
        options[:match_mode] = :extended
        @results = ThinkingSphinx.search @query_l,options
      else
        @mode = "normal"
        @results = ThinkingSphinx.search Riddle::Query.escape(@query),options
      end
      @tags = {}
      #if @results
      #  @results.each {|x|
      #    @tags[x.hosthash] = Tag.find_by_hosthash x.hosthash
      #    @error, @msg = Userhost.add_user_host(x.host, '127.0.0.2')
      #    puts "error: #{@msg}" if @error
      #  }
      #end
    rescue ThinkingSphinx::SphinxError => e
      @error = e.to_s
    end
    [@error, @mode, @results, @tags]
  end
end
