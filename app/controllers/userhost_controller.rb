class UserhostController < ApplicationController
  def index
    
  end
  
  def addhost
    @info = "感谢您的提交，我们会尽快更新！"
    @host = params['host']
    #render :text => @host
    url = Domainatrix.parse(@host)
    if url.domain.size>0 && url.public_suffix
      @userhost = Userhost.create("host"=>@host, "clientip"=>request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip )
      @host = url
    else
      @info = "HOST格式错误"
    end
    #@info = url.inspect
    #render :inline => @info
    render :action => "index"
    #render "index" 
  end
end
