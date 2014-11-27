class StatisticController < ApplicationController
  def index
   @ai = AnalysisInfo.last
   #render inline: @ai["server_info"]
   @server_info_data = get_json_data @ai, 'server_info'
   @cms_info_data = get_json_data @ai, 'cms_info'
   @cloudsec_info_data = get_json_data @ai, 'cloudsec_info'
  end

  def categories
    @rules_data = get_data_from_redis_or_db('rules_data', 60*60*24){Charts.select("#{Charts.table_name}.rule_id, #{Charts.table_name}.value, #{Charts.table_name}.writedate").where("writedate=(select max(writedate) from charts)").order("writedate DESC").to_a}
    @categories = get_data_from_redis_or_db('categories', 60*60*24){
      cats = Category.published
      cats = cats.map {|c|
        chart_rules = c.rules.map{|r|
          rinfo = @rules_data.detect{|d|
            d['rule_id']==r.id
          }
          [r.product, rinfo ? rinfo['value'] : 0]
        }.sort_by{|r| -r[1]}
        [c, chart_rules]
      }
      cats
    }
  end

  def get_data_from_redis_or_db(key, expire)
    data = Sidekiq.redis{|redis|
      redis.get(key)
    }
    if data
      data = JSON.parse(data)
    else
      data = yield
      Sidekiq.redis{|redis|
        redis.setex(key, expire, data.to_json)
      }
    end
    data
  end

  def get_server_info
   @ai = AnalysisInfo.last
   #render inline: @ai["server_info"]
   my_array = []
   JSON.parse(@ai["server_info"]).each{|k,v|
     my_array << [k, v.to_i]
   }
   my_array.sort! { |x, y| y[1] <=> x[1]}
   render text: my_array.to_json
   #render inline: JSON.parse(@ai["server_info"]).map{|k,v| [k,v.to_i+100000] }.to_s
   #render inline: JSON.parse(@ai["server_info"]).sort_by {|_key, value| -value.to_i} .to_s
  end

  private

      def get_json_data(ai, name)
        my_array = []
        if @ai[name]
          JSON.parse(@ai[name]).each{|k,v|
            my_array << [k, v.to_i]
          }
          my_array.sort! { |x, y| y[1] <=> x[1]}
        end
        my_array
      end
end
