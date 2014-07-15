exploits_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'app', 'jobs', 'module', 'httpmodule.rb'))
require exploits_path

module Fofa

  class Exploit

    def initialize(info = {})
      @info = info
    end

    def excute_scansteps(hostinfo)
      @info['ScanSteps'].each{|step|
        if !execute_step(step, hostinfo)
          return false #任何一个测试请求失败都返回FALSE
        end
      }
      true
    end

    def vulnerable(hostinfo)
      excute_scansteps(hostinfo) if @info['ScanSteps']
    end

    def exploit(hostinfo)
      false
    end

    private

    def execute_step(step, hostinfo)
      response = make_request(hostinfo, step['Request'])
      check_response(response, step['ResponseTest'])
    end

    def make_request(hostinfo, request)
      response = Fofa::HttpRequest.row_http(hostinfo, request)
      response
    end

    def check_response(response, test)
      check_one(response, test)
    end

    def check_one(response, test)
      if test[:type]=='item'
        execute_item response, test
      else
        execute_group response, test
      end
    end

    def execute_group(response, test)
      case test[:operation]
        when 'AND'
          test[:checks].each{|t|
            return false unless check_one(response, t)
          }
        when 'OR'
          test[:checks].each{|t|
            return true if check_one(response, t)
          }
      end
    end

    def execute_item(response, test)
      case test[:varibale]
        when '$code'
          test_int(response[:code], test[:operation], test[:value].to_i)
        when '$body'
          test_string(response[:body], test[:operation], test[:value])
        when '$head'
          test_string(response[:head], test[:operation], test[:value])
      end
    end

    def test_string(value, operation, expect_value)
      case operation
        when 'start_with'
          value.start_with?(expect_value)
        when 'end_with'
          value.end_with?(expect_value)
        when 'contains'
          value.include?(expect_value)
        when 'regex'
          value =~ Regexp.new(expect_value)
      end
    end

    def test_int(value, operation, expect_value)
      case operation
        when '=='
          value == expect_value
        when '!='
          value != expect_value
        when '>'
          value > expect_value
        when '<'
          value < expect_value
        when '>='
          value >= expect_value
        when '<='
          value <= expect_value
      end
    end
  end


  module HttpRequest
    def get_web_content(url, req)
      resp = {:error=>true, :errstring=>'', :code=>999, :url=>url, :html=>nil, :redirect_url=>nil}

      begin
        url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
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

        if is_bullshit_ip?(resp[:ip])
          resp[:error] = true
          resp[:errstring] = "bullshit ip"
          return resp
        end
        resp[:port] = uri.port

        http_class = Net::HTTP
        if @options[:proxy]
          aURL = URI.parse('http://'+@options[:proxy])
          proxyHost, proxyPort = [ aURL.host, aURL.port ]
          http_class = Net::HTTP.Proxy(proxyHost, proxyPort)
        end
        http = http_class.new(ip, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.open_timeout = 15
        http.read_timeout = 15
        http.start { |h|
          request = Net::HTTP::Get.new uri.request_uri
          request['Host'] = uri.host
          request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
          request['Accept-Charset'] = 'GBK,utf-8;q=0.7,*;q=0.3'
          request['Accept-Encoding'] = 'gzip,deflate,sdch' unless (ENV['OS'] == 'Windows_NT')  #windows下处理gzip暂时有点问题
          request['Accept-Language'] = 'zh-CN,zh;q=0.8'
          request['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
          req[:header].each {|k,v| request[k] = v}
          begin
            response = h.request request # Net::HTTPResponse object
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

          rescue Timeout::Error => e
            resp[:code] = 999
          rescue =>e
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
        resp[:error] = true
        resp[:errstring] = "Unknown Exception of : #{url}\n error:#{$!} at:#{$@}\nerror : #{err}"
      end

      resp
    end

    def row_http(hostinfo, req)
      http = get_web_content hostinfo, req
      http[:utf8html] = get_utf8(http[:html],http[:header]) if http[:html] and http[:html].size > 2
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