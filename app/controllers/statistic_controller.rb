class StatisticController < ApplicationController
  def index
   @ai = AnalysisInfo.last
   #render inline: @ai["server_info"]
   @server_info_data = get_json_data @ai, 'server_info'
   @cms_info_data = get_json_data @ai, 'cms_info'
   @cloudsec_info_data = get_json_data @ai, 'cloudsec_info'
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
