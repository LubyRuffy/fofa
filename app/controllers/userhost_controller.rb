# encoding: utf-8
require "resque"
require 'uri'
require 'open-uri'
require "#{Rails.root}/app/jobs/url_worker.rb"

class UserhostController < ApplicationController
  def index
    
  end

  def host_of_url(url)
    begin
      url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
      url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
      uri = URI(url)
      uri.host
    rescue => e
      nil
    end
  end
  
  def addhost
    @info = "提交成功，我们会尽快更新（一般5分钟内会自动更新，最长第二天能完成）！"
    @error = false
    @host = params['host']
    @host = host_of_url(@host)
    #render :text => @host
    url = Domainatrix.parse(@host)
    if url.domain.size>0 && url.public_suffix
      @userhost = Userhost.create("host"=>@host, "clientip"=>request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip )
      Resque.enqueue(Processor, @host)
      @host = url

      if @host =~ /\d+\.\d+\.\d+\.\d/
        @info = "暂不支持IP格式，请直接输入域名或者URL"
        @error = true
      end
    else
      @info = "HOST格式错误"
      @error = true
    end
    #@info = url.inspect
    #render :inline => @info
    render :action => "index"
    #render "index" 
  end
end
