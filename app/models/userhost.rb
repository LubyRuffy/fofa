require 'uri'
require 'open-uri'
require 'sidekiq'
require "#{Rails.root}/app/workers/lrlink.rb"
require "#{Rails.root}/app/workers/checkurl.rb"
require "#{Rails.root}/app/workers/realtimeprocess.rb"

include Lrlink

class Userhost < ActiveRecord::Base
  self.table_name="userhost"
  has_many :rule
  belongs_to :user

  def self.add_single_host(user, submit_host, ip, realtime=false)
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
      #host = Userhost.select(:id).where("host=? and DATEDIFF(NOW(),writetime)<90", @host)
      unless Subdomain.es_exists?(@host)
        @userhost = Userhost.create("host"=>@host, "clientip"=>ip.split(',')[0], "writetime"=>Time.now )

        klass = CheckUrlWorker
        klass = RealtimeprocessWorker if realtime

        if user
          @userhost.user = user
          @userhost.save
          klass.perform_async(@host, false, true, user.id)
        else
          klass.perform_async(@host)
        end
      else
        @info = "已经存在相同的记录: #{@host}"
        @error = true
      end
    end
    [@error,@info]
  end

  def self.add_user_host(user, submit_host, ip, realtime=false)
    @info = ''
    @error = false
    if submit_host=~/[,\s]/
      submit_host.split(/[,\s]/).each{|h|
        if h
          h.chomp!
          error,info = add_single_host(user, h, ip, realtime)
          if error
            @error = error
            @info = info
          end
        end

      }
    else
      return add_single_host(user, submit_host, ip, realtime)
    end
    [@error,@info]
  end
end
