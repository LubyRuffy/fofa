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

def hostinfo_of_url(url)
  begin
    url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
    url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
    uri = URI(url)
    rr = uri.host
    rr = rr+':'+uri.port.to_s if uri.port!=80 && uri.port!=443
    rr
  rescue => e
    nil
  end
end

class Userhost < ActiveRecord::Base

  def self.add_user_host(submit_host, ip)
    @info = ''
    @error = false
    @host = submit_host
    @host = hostinfo_of_url(@host)
    url = Domainatrix.parse(@host)
    if url.domain.size>0 && url.public_suffix
      #@host = url
      if @host =~ /\d+\.\d+\.\d+\.\d/
        @info = "暂不支持IP格式，请直接输入域名或者URL"
        @error = true
      end
    else
      @info = "HOST格式错误"
      @error = true
    end
    if !@error
      host = Userhost.select(:id).where("host=? and DATEDIFF(NOW(),writetime)<90", @host)
      if host.size<1
        @userhost = Userhost.create("host"=>@host, "clientip"=>ip.split(',')[0] )
        Resque.enqueue(Processor, @host)
      end
    end
    [@error, @info]
  end
end
