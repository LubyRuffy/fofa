#!/usr/bin/env ruby

#Description:Script for DNS Recon
#Author: Carlos Perez carlos_perez[at]darkoperator.com
require 'open-uri'
require 'json'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/lrlink.rb"
include Lrlink
require 'colorize'

require 'getoptlong'
require 'rubygems'
require 'Net/DNS'
#http://rubyforge.org/projects/pnet-dns/
require 'ip'
#http://rubyforge.org/projects/ip-address/
trap "SIGINT", 'exit'

def axfr(target, nssrv)
  results = []
	res = Net::DNS::Resolver.new
	if nssrv.nil?
	else
		res.nameserver = (nssrv)
	end
	query = res.query(target, "NS")
	if (query)
		(query.answer.select { |i| i.class == Net::DNS::RR::NS}).each do |nsrcd|
			res.nameservers=(nsrcd.nsdname)
			zone = res.axfr(target)
      if zone.answer.length > 0
			#if zone.length > 0
				puts "Zone Transfer Succesfull on Nameserver #{res.nameserver} \n\n".red
				zone.each do |rr|
          #puts rr.inspect
          results << rr.inspect.to_s
        end
        break
			end
		end
  end
  results.uniq
end

#-------------------------------------------------------------------------------
def getAuthDNSServers(dnsserver, domain)
  @dnsserver = dnsserver

  soaips = []
  begin
    authDNSs = @dnsserver.query(domain,Net::DNS::SOA)
    authDNSs.answer.each{|record|
      # Get the IP of this authdns and set it as our new DNS resolver
      if record.class == Net::DNS::RR::SOA
        soadns = record.mname
        # Get the IP of the SOA mname and set it as our new dns resolver
        @dnsserver.query(soadns,Net::DNS::A).answer.each { |arecord|
          soaips << arecord.address.to_s
        }
        return soaips
      else # Is not a SOA response (What could it be?)
        return nil
      end
    }
  rescue Net::DNS::Resolver::NoResponseError => terror
    puts "Error: #{terror.message}"
    return nil
  end
  return nil
end

def getAllDNSServer(dnsserver, domain)
  @dnsserver = dnsserver
  dnsips = []
  begin
    dnss = @dnsserver.query(domain,Net::DNS::NS)
    dnss.answer.each{|record|
      # Get the IP of this authdns and set it as our new DNS resolver
      if record.class == Net::DNS::RR::NS
        dns = record.nsdname
        # Get the IP of the SOA mname and set it as our new dns resolver
        @dnsserver.query(dns,Net::DNS::A).answer.each { |arecord|
          dnsips << arecord.address.to_s
        }
      end
    }
    return dnsips
  rescue Net::DNS::Resolver::NoResponseError => terror
    puts "Error: #{terror.message}"
    return nil
  end
  return nil
end

def dnsbrute(target, wordlist, nssrv)
  subdomains = []
	res = Net::DNS::Resolver.new(:udp_timeout=>15)
	if nssrv.nil?
    dns_ips = getAllDNSServer(res, target)#getAuthDNSServers(res, target)
    dns_ips += %w|8.8.8.8 114.114.114.114 8.8.4.4 208.67.222.222 208.67.220.220 223.5.5.5 223.6.6.6 101.226.4.6 218.30.118.6 123.125.81.6 140.207.198.6|
    puts "====",dns_ips,"===="
    res.nameservers = dns_ips

	else
		res.nameserver = (nssrv)
  end

  #check wildcard
  wildcard_address = []
  wildcard_resp = res.search("fofatestnevercouldexists.#{target}")
  if wildcard_resp && wildcard_resp.answer.size>0
    wildcard_resp.answer.each{|rr|
      wildcard_address << rr.address.to_s if rr.class == Net::DNS::RR::A
    }
  end
  wildcard_resp = res.search("nevercouldexistsfofatest.#{target}")
  if wildcard_resp && wildcard_resp.answer.size>0
    wildcard_resp.answer.each{|rr|
      wildcard_address << rr.address.to_s if rr.class == Net::DNS::RR::A
    }
  end
  puts "Wildcard resolution is enabled on this domain: #{wildcard_address}".red if wildcard_address.size>0

	arr = []
	i, a = 0, []
	begin
		arr = IO.readlines(wordlist)
	rescue
		puts "Could not open file #{wordlist}"
	end
	arr.each do |line|
		if i < 10
			a.push(Thread.new {
					begin
            print '.'
						query1 = res.search("#{line.chomp}.#{target}")
						if (query1)
							query1.answer.each do |rr|
								if rr.class == Net::DNS::RR::A || rr.class == Net::DNS::RR::CNAME
									unless wildcard_address.include?(rr.address.to_s)
                    print "#{line.chomp}.#{target},#{rr.address}\n"
                    subdomains << "#{line.chomp}.#{target}"
                  end
								end
							end
            end
            sleep 1
					end
				})
			i += 1
		else
			sleep(0.01) and a.delete_if {|x| not x.alive?} while not a.empty?
			i = 0
		end
	end
	a.delete_if {|x| not x.alive?} while not a.empty?
  subdomains.uniq
end

# max item size is 64
def get_domain_from_google_ajax(domain)
  subdomains = []
  (1..8).each{|n|
    print '.'
    added = false
    added_arr = []
    url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&rsz=8&start=#{(n-1)*8}&q=site%3A#{domain}"
    info = JSON.parse(open(url).read)
    if info['responseStatus'] != 200
      break
    end
    info['responseData']['results'].each{|r|
      hostinfo = hostinfo_of_url(r['url'])
      if !subdomains.include?(hostinfo)
        added = true
        added_arr << hostinfo
        subdomains << hostinfo
      end
    }
    unless added
      break
    end
    #puts added_arr
  }
  subdomains.uniq
end

def get_domain_from_google(domain)
  subdomains = []
  (1..100).each{|n|
    print '.'
    #puts "==============PAGE #{n}==============="
    added = false
    added_arr = []

    url = "https://ipv6.google.com.hk/search?hl=en&lr=&ie=UTF-8&q=site%3A" + domain + "&start=" + (n*100).to_s + "&sa=N&filter=0&num=100"
    #puts url
    get_linkes(open(url).read).select{|l|
      domain_info = get_domain_info_by_host(l)
      return false unless domain_info
      l_domain = domain_info.domain+'.'+domain_info.public_suffix
      l_domain.downcase.include?(domain.downcase)
    }.each{|l|
      hostinfo = hostinfo_of_url(l)
      if !subdomains.include?(hostinfo)
        added = true
        added_arr << hostinfo
        subdomains << hostinfo
      end
    }
    unless added
      break
    end
    #puts added_arr
  }
  subdomains.uniq
end

def get_domain_from_ilinks(domain)
  require 'net/http'
  subdomains = []
  url = URI.parse("http://i.links.cn/subdomain/")

  Net::HTTP.start(url.host, url.port) do |http|
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({ 'domain' => domain, 'b2' => '1' , 'b3' => '1' , 'b4' => '1' })
    get_linkes(http.request(req).body).select{|l|
      domain_info = get_domain_info_by_host(l)
      return false unless domain_info
      l_domain = domain_info.domain+'.'+domain_info.public_suffix
      l_domain.downcase.include?(domain.downcase)
    }.each{|l|
      hostinfo = hostinfo_of_url(l)
      if !subdomains.include?(hostinfo)
        subdomains << hostinfo
      end
    }
  end

  subdomains.uniq
end


#-------------------------------------------------------------------------------
def usage
	puts "This tool provides diferent methods for enumerating subdomains."
	print( "
-d, --target
		Domain to be targeted for enumeration.

-w, --wordlist
		Wordlist to be use for brutforce enumeration of host names and subdomains.

-s, --dns
		Alternate DNS server to use.

-h, --help
		This help message.
"
	)
end



#Main
#-------------------------------------------------------------------------------

dnssrv = nil
wordlist = File.join(@root_path, 'data/subdomains-top1mil-5000.txt')
trgtdom = 'baidu.com'
opts = GetoptLong.new(
      	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    	[ '--dns','-s', GetoptLong::OPTIONAL_ARGUMENT ],
      	[ '--wordlist','-w', GetoptLong::OPTIONAL_ARGUMENT ],
	[ '--target','-d', GetoptLong::OPTIONAL_ARGUMENT ]
    )
opts.each do |opt, arg|
	case opt
        	when '--help'
			usage()
		when '--dns'
			dnssrv = arg
		when '--wordlist'
			if File.exist?(arg)
	  			wordlist = arg
			else
				puts "File #{arg} does not exist."
				exit 0
			end
		when '--target'
			trgtdom = arg
      	end
end

def addhost(hosts)
  uri = URI('http://www.fofa.so/api/addhostp')
  res = Net::HTTP.post_form(uri, 'host' => hosts.join(','))
  puts "response:"+res.body
end

puts "Trying Zone Transfers..."
##### axfr #####
results = axfr(trgtdom, dnssrv)
if results.size>0
  puts "Good!".green
else
  puts "Zone transfer is not allowed in any of it's NS.".red

  ##### ilinks #####
  ilinks_results = []
  puts "Trying ilinks:"
  ilinks_results += get_domain_from_ilinks(trgtdom)
  puts "\nFound #{ilinks_results.size} result from ilinks!".green
  #puts ilinks_results
  addhost(ilinks_results)

  ##### google #####
  google_results = []
  puts "Trying google search:"
  google_results += get_domain_from_google(trgtdom)
  puts "\nFound #{google_results.size} result from google!".green
  #puts google_results
  addhost(google_results)

  ##### bruteforce #####
  brute_results = []
  puts "Trying bruteforce:"
  brute_results += dnsbrute(trgtdom, wordlist, dnssrv)
  puts "\nFound #{brute_results.size} result from bruteforce!".green
  addhost(brute_results)

  results = ilinks_results + google_results + brute_results
end
puts "=============="
results.uniq.each{|r|
  puts r
}
