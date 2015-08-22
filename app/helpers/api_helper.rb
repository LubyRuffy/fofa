module ApiHelper
  def search_sphinxql(query, page_count=1000)
    @results = Subdomain.search query
  end

  def search(query, page_count=10, page=1, highlight=false, source=['host', 'title', 'lastupdatetime', 'ip', 'header'])
    @query = query
    @error = nil
    @mode = "normal"
    @tags = {}

    if @query.nil? || @query.size<1
      @results = Subdomain.__elasticsearch__.search(query: {match_all: {}},
                                         _source: source,
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
        #puts "QueryParser failed:"+e.inspect+e.backtrace.to_s
      end

      @results = nil
      #begin
        if @query_l
          @mode = "extended"
        else
          #highlight = false
          @query_l = %Q|
          {
              "function_score": {
                "query": {
                  "query_string": {
                    "query": "#{@query.query_escape}*"
                  }
                },
                "score_mode": "multiply",
                "boost_mode": "multiply",
                "functions": [
                  {
                    "filter": {
                      "query": {
                        "query_string": {
                          "query": "domain:#{@query.query_escape}"
                        }
                      }
                    },
                    "boost_factor": 200
                  },
                  {
                    "filter": {
                      "query": {
                        "query_string": {
                          "query": "host:*#{@query.query_escape}"
                        }
                      }
                    },
                    "boost_factor": 100
                  },
                  {
                    "filter": {
                      "query": {
                        "query_string": {
                          "query": "ipstr:#{@query.query_escape}*"
                        }
                      }
                    },
                    "boost_factor": 100
                  },
                  {
                    "filter": {
                      "query": {
                        "query_string": {
                          "query": "header:#{@query.query_escape}"
                        }
                      }
                    },
                    "boost_factor": 50
                  },
                  {
                    "filter": {
                      "query": {
                        "query_string": {
                          "query": "body:#{@query.query_escape}"
                        }
                      }
                    },
                    "boost_factor": 1
                  }
                ]
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
          _source: source,
          query: JSON.parse(@query_l),
      }
      @query_l[:highlight] = {pre_tags: ["<mark>"],post_tags: ["</mark >"],fields: {header_ok: {fragment_size: 2000}}} if highlight
      if @mode == "extended"
        @query_l[:sort] = [{lastupdatetime: "desc"}, {_score: "desc"}]
      end
      @results = Subdomain.__elasticsearch__.search(@query_l).paginate(page: page, per_page: page_count)
      #rescue => e
      #  @error = e.to_s
      #end
    end
    [@error, @mode, @results, @tags, @query_l]
  end

  def search_url(query, page, per_page=1000)
    search(query, per_page, page, false, ['host'])
  end
end
