#!/usr/bin/env ruby
require 'domainatrix'

def get_ip_of_host(host)
  require 'socket'
  ip = Socket.getaddrinfo(host, nil)
  return nil if !ip || !ip[0] || !ip[0][2]
  ip[0][2]
rescue => e
  nil
end

def get_root_of_host(host)
  begin
    url = Domainatrix.parse(host)
    if url.domain && url.public_suffix
      return url.domain+'.'+url.public_suffix
    end
  rescue => e
    return nil
  end
end

STDOUT.sync = true
while host = gets
  host = host.strip
  break unless host && host.size>1
  ip = get_ip_of_host(host)
  next unless ip
  rootdomain = get_root_of_host(host)
  #break unless rootdomain
  puts host+"\t"+rootdomain+"\t"+ip
end
