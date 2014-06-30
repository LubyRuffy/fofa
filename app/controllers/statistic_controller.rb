class StatisticController < ApplicationController
  def index
   @ai = AnalysisInfo.last
   #render inline: @ai["server_info"]
  end

  def get_server_info
   @ai = AnalysisInfo.last
   render inline: @ai["server_info"]
  end
end
