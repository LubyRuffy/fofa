require 'uri'
require 'open-uri'
require 'sidekiq'
require "#{Rails.root}/app/workers/url_worker.rb"
require "#{Rails.root}/app/workers/module/lrlink.rb"

include Lrlink

class Userhost < ActiveRecord::Base
  has_many :rule

  def self.add_single_host(submit_host, ip, realtime=false)
    @info = ''
    @error = false
    @host = submit_host
    @host = hostinfo_of_url(@host)
    if !@host
      @info = "HOST格式错误: #{submit_host}"
      @error = true
    else
      url = Domainatrix.parse(@host)
      if url.domain.size<1 || !url.public_suffix
        @info = "HOST格式错误: #{@host}"
        @error = true
      end
    end
    if !@error
      host = Userhost.select(:id).where("host=? and DATEDIFF(NOW(),writetime)<90", @host)
      if host.size<1
        @userhost = Userhost.create("host"=>@host, "clientip"=>ip.split(',')[0] )
        queue = "process_url"
        queue = "realtime_process_url" if realtime
        Sidekiq::Client.enqueue_to(queue, Processor, @host)
      end
    end
    [@error,@info]
  end

  def self.add_user_host(submit_host, ip, realtime=false)
    @info = ''
    @error = false
    if submit_host=~/[,\s]/
      submit_host.split(/[,\s]/).each{|h|
        if h
          h.chomp!
          error,info = add_single_host(h, ip, realtime)
          if error
            @error = error
            @info = info
          end
        end

      }
    else
      return add_single_host(submit_host, ip, realtime)
    end
    [@error,@info]
  end
end
