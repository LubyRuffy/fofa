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
     my_array << {'value'=>v.to_i, 'label'=>k}
   }
   render text: my_array.to_json
   #render inline: JSON.parse(@ai["server_info"]).map{|k,v| [k,v.to_i+100000] }.to_s
   #render inline: JSON.parse(@ai["server_info"]).sort_by {|_key, value| -value.to_i} .to_s
  end

  private
      def get_json_data(ai, name)
        my_array = []
        my_colors= ['#c12e34','#e6b600','#0098d9','#2b821d',
                    '#005eaa','#339ca8','#cda819','#32a487',
                    '#50B432', '#ED561B', '#DDDF00', '#24CBE5',
                    '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
        my_hash = JSON.parse(ai[name])
        JSON.parse(ai[name]).each{|k,v|
          my_array << {'value'=> v.to_i, 'label'=>k}
        }
        my_array.sort! { |x, y| y['value'] <=> x['value']}

        i=0
        my_array.each {|x|
          x['color'] = my_colors[i]
          i+=1
        }
      end
end
