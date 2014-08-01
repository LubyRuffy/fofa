class FofacliController < ApplicationController
  def index
    @exploits = Exploits.all
  end

  def getstarted
  end

  def commandline
  end

  def howtoexploit

  end

  def download
    require_user
    redirect_to '/fofacli-0.0.1.zip'
  end
end
