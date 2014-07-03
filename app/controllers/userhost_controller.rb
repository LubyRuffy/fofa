# encoding: utf-8
require "resque"
require "#{Rails.root}/app/jobs/url_worker.rb"

class UserhostController < ApplicationController
  def index
    
  end


  
  def addhost
    @info = "提交成功，我们会尽快更新（一般5分钟内会自动更新，最长第二天能完成）！"
    @rawurl = params['host']
    @error, @msg = Userhost.add_user_host(@rawurl,request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip)
    @info = @msg if @error
    render :action => "index"
  end
end
