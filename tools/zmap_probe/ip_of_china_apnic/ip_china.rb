#!/usr/bin/env ruby
require 'ipaddr'
require 'netaddr'

@root_path = File.expand_path(File.dirname(__FILE__))
@apnic_file = File.join(@root_path,'delegated-apnic-latest')
puts @apnic_file
unless File.exist?(@apnic_file)
  `wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest`
  unless File.exist?(@apnic_file)
    puts "download apnic data failed, now quiting..."
    exit(-1)
  end
end

File.open(@apnic_file, 'r') {|f|
  f.each_line{|l|
    puts l
    if l.include?("apnic|CN|ipv4")
      registry,cc,ip_type,start_ip,value,first_date,status = l.split("|")
      start_ip_s=IPAddr.new(start_ip)
      ip_from=start_ip_s.to_i
      ip_to=ip_from+value.to_i-1
      puts "#{start_ip} - #{IPAddr.new(ip_to,Socket::AF_INET).to_s}"
      ip_net_range = NetAddr.range(ip_from, ip_to, :Inclusive => true, :Objectify => true)
      cidrs = NetAddr.merge(ip_net_range, :Objectify => true)
      puts cidrs
    end
  }
}