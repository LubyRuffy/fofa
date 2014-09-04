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

  def howtorule

  end

  def developer

  end

  def download
    require_user
    redirect_to '/fofacli-0.0.2.zip'
  end
end
