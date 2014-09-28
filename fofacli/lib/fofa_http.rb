require 'net/http'
require 'uri'
require 'open-uri'
require 'guess_html_encoding'

module Fofa
  module HttpRequest


    def self.get_web_content(url, req)
      resp = {:error=>true, :errstring=>'', :code=>999, :url=>url, :html=>nil, :redirect_url=>nil}

      begin
        url=url+'/' unless url.include?('/')
        url = 'http://'+url if !url.include?('http://') and !url.include?('https://')
        url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
        uri = URI(url)
        ip = uri.host
        resp[:host] = uri.host
        ip = uri.host
        if ip =~ /^[0-9.]*$/
          resp[:ip] = ip
        else
          ip = Socket.getaddrinfo(uri.host, nil)
          return resp if !ip || !ip[0] || !ip[0][2]
          resp[:ip] = Socket.getaddrinfo(uri.host, nil)[0][2]
          ip = resp[:ip]
        end

        resp[:port] = uri.port

        http_class = Net::HTTP
        proxy = req[:proxy] if req
        proxy ||= ENV['FOFA_PROXY']
        if proxy
          aURL = URI.parse('http://'+proxy)
          proxyHost, proxyPort = [ aURL.host, aURL.port ]
          http_class = Net::HTTP.Proxy(proxyHost, proxyPort)
        end
        #http = http_class.new(ip, uri.port)
        http = http_class.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.open_timeout = 15
        http.read_timeout = 15
        #http.set_debug_output($stdout)
        http.start { |h|
          begin
            response = h.send_request(req[:method], uri.request_uri, req[:data],  req[:header])
            resp[:code] = response.code
            resp[:message] = response.message
            resp[:http_version] = response.http_version

            header = ["HTTP/#{response.http_version} #{response.code} #{response.message}"]
            response.header.each_capitalized() {|k, v|
              header << [k,v].join(': ')
            }
            header = header.join("\n")

            resp[:header] = header.force_encoding('UTF-8')
            resp[:html] = nil
            if response.header[ 'Content-Encoding' ].eql?( 'gzip' )
              sio = StringIO.new( response.body )
              gz = Zlib::GzipReader.new( sio )
              html = gz.read()
              resp[:html] = html
            elsif response.header[ 'Content-Encoding' ].eql?( 'deflate' )
              zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
              html = zstream.inflate(response.body)
              zstream.finish
              zstream.close
              resp[:html] = html
            else
              resp[:html] = response.body
            end
            resp[:bodysize] = resp[:html].size
            resp[:error] = false

            if response['location']
              resp[:redirect_url] = response['location']
            end
=begin
            if response.code.to_i == 301 || response.code.to_i == 302
              ops[:following] += 1
              return resp if ops[:following]>2

              #  puts "redirect"
              if response['location'].include?("http://")
                return get_web_content(response['location'], ops)
              else
                return get_web_content("http://"+resp[:host]+"/"+response['location'], ops)
              end
            end

            if response['content-length'] && response['content-length'].to_i<200
              if resp[:html]=~/<META\s*HTTP-EQUIV=[\'\"]REFRESH[\'\"]\s*CONTENT=[\'\"]\d;\s*URL=(.*)[\'\"]\s*>/i
                resp[:html].scan(/<META\s*HTTP-EQUIV=[\'\"]REFRESH[\'\"]\s*CONTENT=[\'\"]\d;\s*URL=(.*)[\'\"]\s*>/i).each{|x|
                  ops[:following] += 1
                  return resp if ops[:following]>2
                  loc = x[0]
                  if loc.include?("http://")
                    return get_web_content(loc, ops)
                  else
                    return get_web_content("http://"+resp[:host]+"/"+loc, ops)
                  end
                }
              end

              if resp[:html]=~/location.href\s*=\s*["'](.*?)["']/i
                resp[:html].scan(/location.href\s*=\s*["'](.*?)["']/i).each{|x|
                  ops[:following] += 1
                  loc = x[0]
                  if loc.include?("http://")
                    return get_web_content(loc, ops)
                  else
                    return get_web_content("http://"+resp[:host]+"/"+loc, ops)
                  end
                }
              end
            end
=end
          rescue Timeout::Error => e
            resp[:code] = 999
          rescue =>e
            puts e
            resp[:code] = 998
          end
        }
      rescue Timeout::Error  => the_error
        resp[:error] = true
        resp[:errstring] = "Timeout::Error of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
      rescue OpenURI::HTTPError => the_error
        resp[:error] = true
        resp[:errstring] = "OpenURI::HTTPError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
      rescue SystemCallError => the_error
        resp[:error] = true
        resp[:errstring] = "SystemCallError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
      rescue SocketError => the_error
        resp[:error] = true
        resp[:errstring] = "SocketError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
      rescue => err
      	puts err
        resp[:error] = true
        resp[:errstring] = "Unknown Exception of : #{url}\n error:#{$!} at:#{$@}\nerror : #{err}"
      end

      resp
    end

    def self.get_utf8_html(c,header=nil)
	    encoding = GuessHtmlEncoding.guess(c,header)
	
	    if(encoding)
	      encoding = "GB2312" if (encoding=='GBK2312') || (encoding=='GB_2312-80') || encoding.include?('2312')#bug?
	      encoding = "UTF-8" if (encoding.include?('UTF')) || (encoding=='U1TF-8') || (encoding=='UF-8') #bug?
	      encoding = "SHIFT_JIS" if (encoding=='SHIFT-JIS') || (encoding=='X-SJIS') || encoding==('SHFIT_JIS') || (encoding=='SHIT-JIS') || (encoding=='SHIFT_JS') || (encoding=='S-JIS') || (encoding=='SHIF_JIS') || (encoding=='SJIS-WIN') || (encoding=='S-JIS') || encoding=="X-EUC-JP" || encoding=='X-SJIS-JP'#bug?
	      encoding = "cp1251" if encoding.include?('1251') ||  encoding.include?('1250') #bug?
	      encoding = "iso-8859-1" if encoding=='ISO-8855-1' || encoding=='IS0-8859-1' || encoding.include?('8859-1') || encoding.include?('8858-1')  #bug?
	      encoding = "iso-8859-2" if encoding=='ISO8859_2' || encoding=='EN_US' || encoding.include?('8859') #bug?
	      encoding = "euc-kr" if encoding.include?('5601') || encoding=='EUC_KR' || encoding=='KOREAN' || encoding=='EUK-KR' || encoding=='KO' || encoding=='X-EUC' || encoding=='ECU-KR' || encoding=='MS949'
	
	      if Encoding.name_list.select{|e| e==encoding}.empty?
	        found = false
	        Encoding.name_list.each{|e|
	          if e!='ASCII-8BIT' && e!='US-ASCII' && c.force_encoding(e).valid_encoding?
	            encoding = e
	            found = true
	            break
	          end
	          encoding = 'UTF-8' unless found
	        }
	      end
	
	      if(encoding.to_s != "UTF-8")
	        c = c.force_encoding(encoding)
	        c = c.encode('UTF-8', :undef => :replace, :invalid => :replace, :replace => '^')
	      else
	        c = c.force_encoding("UTF-8") if c.encoding != 'UTF-8'
	        c.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => '^')
	        #
	      end
	    else
	      c = c.force_encoding('UTF-8')
	      if !c.valid_encoding?
	        c = c.force_encoding("GB18030")
	        c = c.encode('UTF-8', :undef => :replace, :invalid => :replace, :replace => '^')
	      end
	    end
	
	    if !c.valid_encoding?
	      c = c.force_encoding("GB18030")
	      if !c.valid_encoding?
	        return ''
	      end
	      c = c.encode('UTF-8', :undef => :replace, :invalid => :replace, :replace => '^')
	    end
	
	    c
    end

    def self.row_http(hostinfo, req)
      http = get_web_content hostinfo+req[:uri], req
      http[:utf8html] = get_utf8_html(http[:html],http[:header]) if http[:html] and http[:html].size > 2
      if http[:utf8html]
        arr = http[:utf8html].scan(/<title>(.*?)<\/title>/i)
        http[:title] = ''
        if arr.size>0
          http[:title] = arr[0][0].strip
        end
        http[:title] = http[:title].force_encoding('utf-8')
      end
      http
    end

  end
end