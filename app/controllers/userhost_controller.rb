# encoding: utf-8
require "sidekiq"

class UserhostController < ApplicationController
  def index
    
  end


  
  def addhost

    @info = "提交成功，我们会尽快更新（一般5分钟内会自动更新，最长第二天能完成）！<br/><a href='/info/points'>成功添加记录之后，你的贡献积分将会+1。</a>"
    @rawurl = params['host']
    @error, @msg = Userhost.add_user_host(current_user, @rawurl,request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip, true)
    @info = @msg if @error
    render :action => "index"
  end
end
