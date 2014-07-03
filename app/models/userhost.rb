require "resque"
require 'uri'
require 'open-uri'
require "#{Rails.root}/app/jobs/url_worker.rb"

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

class Userhost < ActiveRecord::Base

  def self.add_user_host(submit_host, ip)
    @info = ''
    @error = false
    @host = submit_host
    @host = host_of_url(@host)
    url = Domainatrix.parse(@host)
    if url.domain.size>0 && url.public_suffix
      @userhost = Userhost.create("host"=>@host, "clientip"=>ip.split(',')[0] )
      Resque.enqueue(Processor, @host)
      #@host = url
      if @host =~ /\d+\.\d+\.\d+\.\d/
        @info = "暂不支持IP格式，请直接输入域名或者URL"
        @error = true
      end
    else
      @info = "HOST格式错误"
      @error = true
    end
    [@error, @info]
  end
end
