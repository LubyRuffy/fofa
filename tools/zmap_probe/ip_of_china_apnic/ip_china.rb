#!/usr/bin/env ruby
require 'ipaddr'

@root_path = File.expand_path(File.dirname(__FILE__))
@apnic_file = File.join(@root_path,'delegated-apnic-latest')

unless File.exist?(@apnic_file)
  `wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest`
  unless File.exist?(@apnic_file)
    puts "download apnic data failed, now quiting..."
    exit(-1)
  end
end

#require 'netaddr'
#ip_net_range = NetAddr.range("223.255.252.0", "223.255.253.255", :Inclusive => true, :Objectify => true)
#cidr = NetAddr.merge(ip_net_range, :Objectify => true)
#puts cidr
#exit

@cidrs = []
STDOUT.sync=true
STDERR.sync=true
File.open(@apnic_file, 'r') {|f|
  i = 0
  f.each_line{|l|
    i+=1
    $stderr.print "\r#{i}" if i%100==0
    if l.include?("apnic|CN|ipv4")
        registry,cc,ip_type,start_ip,value,first_date,status = l.split("|")
        cidr = "#{start_ip}/#{32-value.to_i.to_s(2).size+1}"
        #puts cidr
        #start_ip_s=IPAddr.new(start_ip)
        #ip_from=start_ip_s.to_i
        #ip_to=ip_from+value.to_i-1
        #puts "#{start_ip} - #{IPAddr.new(ip_to,Socket::AF_INET).to_s}"
        @cidrs << cidr
    end
  }
}

@cidrs.each{ |cidr|
  $stdout.puts cidr
}
