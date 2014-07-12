require "resque"
require 'resque-loner'
require 'uri'
require 'open-uri'
require "#{Rails.root}/app/jobs/url_worker.rb"
require "#{Rails.root}/app/jobs/module/lrlink.rb"

class Userhost < ActiveRecord::Base
  include Lrlink

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

  def self.add_single_host(submit_host, ip)

    @info = ''
    @error = false
    @host = submit_host
    @host = hostinfo_of_url(@host)
    url = Domainatrix.parse(@host)
    if url.domain.size<1 || !url.public_suffix
      @info = "HOST格式错误: #{@host}"
      @error = true
    end
    if !@error
      host = Userhost.select(:id).where("host=? and DATEDIFF(NOW(),writetime)<90", @host)
      if host.size<1
        @userhost = Userhost.create("host"=>@host, "clientip"=>ip.split(',')[0] )
        Resque.enqueue(Processor, @host)
      end
    end
    [@error,@info]
  end

  def self.add_user_host(submit_host, ip)
    @info = ''
    @error = false
    if submit_host.include? ","
      submit_host.split(',').each{|h|
        error,info = add_single_host(h, ip)
        if error
          @error = error
          @info = info
        end

      }
    else
      return add_single_host(submit_host, ip)
    end
    [@error,@info]
  end
end
