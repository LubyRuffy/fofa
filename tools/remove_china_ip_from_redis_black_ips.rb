#!/usr/bin/env ruby
# 删除black_ips中的国内ip

require 'sidekiq'
require 'geoip'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../config/initializers/sidekiq.rb"

@geoip = GeoIP.new(@root_path+'/data/GeoIP.dat')
Sidekiq.redis {|redis|

  redis.smembers("black_ips").each{|ip|
    begin
      fullip = ip+'.100'
      country = @geoip.country(fullip).to_hash[:country_name]
      puts ip
      if country == 'China'
        puts "srem #{ip} from black_ips"
        redis.srem("black_ips", ip)
      end
    rescue => e
    end
  }

}