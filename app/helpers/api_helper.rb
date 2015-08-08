module ApiHelper
  def search_sphinxql(query, page_count=1000)
    @results = Subdomain.search query
  end

  def search(query, page_count=10, page=1)
    @query = query
    @error = nil
    @mode = "normal"
    @tags = {}

    if @query.nil? || @query.size<1
      @results = Subdomain.__elasticsearch__.search(query: {match_all: {}},
                                         _source: ['host', 'title', 'lastupdatetime', 'ip', 'header'],
                                         sort: [
                                             {
                                                 lastupdatetime: "desc"
                                             }
                                         ]).paginate(page: page, per_page: page_count)
    else
      @query_l = nil
      begin
        @query_l = SearchHelper::ElasticProcessorBool.parse(@query)
      rescue => e #Parslet::ParseFailed
        puts "QueryParser failed:"+e.inspect+e.backtrace.to_s
      end

      @results = nil
      #begin
        if @query_l
          @mode = "extended"
        else
          @query_l = %Q|
          {
              "query_string": {
                  "query": "#{@query.query_escape}",
                  "analyze_wildcard": true
              }
          }|
        end
        #if @results
        #  @results.each {|x|
        #    @tags[x.host] = Tag.find_by_host x.host
        #    @error, @msg = Userhost.add_user_host(current_user, x.host, '127.0.0.2')
        #    puts "error: #{@msg}" if @error
        #  }
        #end
      @query_l = {
          _source: ['host', 'title', 'lastupdatetime', 'ip', 'header'],
          query: JSON.parse(@query_l),
          sort: [

              {
                  lastupdatetime: "desc"
              },
              {
                  _score: "desc"
              }
          ]
      }
        @results = Subdomain.__elasticsearch__.search(@query_l).paginate(page: page, per_page: page_count)
      #rescue => e
      #  @error = e.to_s
      #end
    end
    [@error, @mode, @results, @tags, @query_l]
  end

  def search_url(query, page, per_page=1000)
    @query = query
    @query_l = nil
    begin
      @query_l = SearchHelper::ElasticProcessor.parse(@query)
    rescue => e #Parslet::ParseFailed
      puts "QueryParser failed:"+e.inspect+e.backtrace.to_s
    end

    @results = nil
    begin
      @max_id = 1
      (1..page).each{|i|
        options = {:match_mode => :extended, :index => 'subdomain_core',
                   :with => {:id => @max_id..9999999999},
                   :sql => { :select => 'id,host'}, :per_page => per_page,
                   :page => 1, :order => "id asc"}
        if @query_l
          @mode = "extended"
          options[:match_mode] = :extended
          #options[:order] = "lastupdatetime DESC"
          @results = ThinkingSphinx.search @query_l,options
        else
          @mode = "normal"
=begin
          if @query.size>0
            options[:field_weights] = {
                :ip => 10000,
                :host => 400,
                :title => 50,
                :header    => 20,
                :body => 1
            }
          else
            options[:order] = "lastupdatetime DESC"
          end
=end
          @results = ThinkingSphinx.search Riddle::Query.escape(@query),options
        end
        @results.each{|r|
          @max_id = [@max_id, r.id.to_i].max
        }
        @max_id += 1
      }
    rescue ThinkingSphinx::SphinxError => e
      @error = e.to_s
    end
    [@error, @mode, @results, @tags]
  end
end
