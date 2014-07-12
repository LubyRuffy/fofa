require "resque"
require 'resque-loner'
require 'uri'
require 'open-uri'
require "#{Rails.root}/app/jobs/url_worker.rb"
require "#{Rails.root}/app/jobs/module/lrlink.rb"

include Lrlink

class Userhost < ActiveRecord::Base
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
