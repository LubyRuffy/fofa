# encoding: utf-8

require 'net/http'
require 'uri'
require 'open-uri'
require 'guess_html_encoding'
require 'nokogiri'
require 'fileutils'
require 'digest'
require 'pathname'
require 'base64'
require "json"
require "sixarm_ruby_magic_number_type"

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

module HttpModule
  def post_img_data_to_webscan(img_data, img_path)
    # Token used to terminate the file in the post body. Make sure it is not
    # present in the file you're uploading.
    boundary = "upload_img_test_AaB03x"

    uri = URI.parse("http://webscan.360.cn/timgurl/jy")

    ext = img_data.magic_number_type
    puts ext

    post_body = []
    post_body << "--#{boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"upfile\"; filename=\"#{File.basename(img_path)}\"\r\n"
    post_body << "Content-Type: image/#{ext}\r\n"
    post_body << "\r\n"
    post_body << img_data
    post_body << "\r\n--#{boundary}--\r\n"

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = post_body.join
    request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"

    response = http.request(request)
    data = JSON.parse(response.body)
    if data['error'] && data['url']
      data['url']
    else
      puts data
      nil
    end
  end

  def post_img_to_webscan(img_path)
    if img_path.length < 1 then
      puts "error : need input a image file to send"
      exit
    end

    img_data = File.read(img_path)
    post_img_data_to_webscan(img_data, img_path)
  end

  def post_img_url_to_webscan(img_url, referer=nil)
    return img_url if img_url.include? "qhimg.com"
    #http://webscan.360.cn/timgurl/url    post  参数名:url
    uri = URI.parse("http://webscan.360.cn/timgurl/url")
    if referer
      url = "http://proxy.fofa.so/image.php?ref=#{URI.encode(referer)}&img=#{URI.encode(img_url)}" 
    else
      url = img_url
    end
    begin
      response = Net::HTTP.post_form(uri, 'url' => url)
      #puts url
      data = JSON.parse(response.body)
      #puts data
      if data['error'] && data['url']
        data['url']
      else
        #puts data
        nil
      end
    rescue => e
      @logger.error "post_img_url_to_webscan error of #{img_url} from #{referer}" if @logger
    end

  end

  def get_web_content(url,ops=nil)

    @options ||= {}
    ops ||= {:following => 0}
    ops[:following] = 0 if !ops.has_key?(:following)
    resp = {:error=>true, :errstring=>'', :code=>999, :url=>url, :html=>nil, :redirect_url=>nil}

    begin
      url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
      url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
      uri = URI(url)
      ip = uri.host
      ip = ops[:hostip] if ops[:hostip]
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
        request['Referer'] = ops[:referer] if ops && ops[:referer]
        begin
          response = h.request request # Net::HTTPResponse object
          resp[:code] = response.code
          resp[:message] = response.message
          resp[:http_version] = response.http_version
          resp[:header] = response.header
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

  def get_utf8(c)
    encoding = GuessHtmlEncoding.guess(c)
    encoding = "GB2312" if encoding=='GBK2312' #bug?
    begin
      #puts encoding
      if(encoding)
        if(encoding.to_s != "UTF-8")
          c = c.force_encoding(encoding)
          c = c.encode('UTF-8', :invalid => :replace, :replace => '^')
        else
          #c = c.force_encoding('UTF-8')
        end
      else
        c = c.force_encoding('UTF-8')
        if !c.valid_encoding?
          c = c.force_encoding("GB18030")
          if !c.valid_encoding?
            return ''
          end
          c = c.encode('UTF-8', :invalid => :replace, :replace => '^')
        end
      end

      if !c.valid_encoding?
        c = c.force_encoding("GB18030")
        if !c.valid_encoding?
          return ''
        end
        c = c.encode('UTF-8', :invalid => :replace, :replace => '^')
      end
    rescue => e
      puts "error of "+e.backtrace.inspect
    end

    c
  end

  def get_http(url, refer=nil)
    http = get_web_content url, referer: refer
    http[:utf8html] = get_utf8 http[:html] if http[:html] and http[:html].size > 2
    if http[:utf8html]
      arr = http[:utf8html].scan(/<title>(.*?)<\/title>/i)
      if arr.size>0
        http[:title] = arr[0][0].strip
      else
        page = Nokogiri::HTML(http[:utf8html])
        title_s = page.css('title')
        title_s = page.at_css('title') if !title_s
        http[:title] = title_s[0].text if title_s && title_s[0]
        http[:title] ||= ''
      end
    end
    #puts http[:utf8html]
    http
  end

  def dump_obj_to_file(filename, obj)
    FileUtils.mkdir_p(File.split(filename).first) unless File.exists?(filename)
    File.open(filename, 'w') do |f|
      obj[:time] = Time.now.strftime("%Y-%m-%d %H:%M:%S")  #加入保存时间
      Marshal.dump(obj, f)
    end
  end

  def load_obj_from_file(filename)
    File.open(filename, 'r') do |f|
      return Marshal.load(f)
    end
    nil
  end


  def load_info(url, referer=nil)
    @options ||= {}
    http_info = nil
    url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
    uri = nil
    begin
      uri = URI(url)
    rescue URI::InvalidURIError
      return nil
    end
    path = File.join(File.dirname(__FILE__), 'results', Digest::MD5.hexdigest(url)+'.tobj')

    #先看文件是否存且时间小于1天
    if File.exists?(path) && !@options[:no_cache]
      http_info = load_obj_from_file path

      if @logger
        @logger.debug url
        @logger.debug path
      end

      #2小时更新一次
      if Time.parse(http_info[:time]) + @options[:cachetime].to_i < Time.now
        http_info = nil
      end
    end

    #不存在或者时间超时，则重新获取信息
    if !http_info
      http_info = get_http(url, referer)
      if !http_info[:error]
        dump_obj_to_file path, http_info
      end
    end
    http_info
  end

  def download_img(img_src, refer)
    @options ||= {}
    img_src = URI.encode(img_src) unless img_src.include? '%' #如果包含百分号%，说明已经编码过了
    is_img_data = img_src.include? 'data:image/' #src 就是图片数据
    if refer
      u = URI.join(refer, img_src)
    else
      u = URI(img_src)
    end
    abs_img_url = u.to_s
    path = File.join(File.dirname(__FILE__), 'imgs')
    path = File.join(File.dirname(__FILE__), '../'+@options[:img_save_path]) if @options[:img_save_path]
    FileUtils.mkdir_p path
    filename = Digest::MD5.hexdigest(abs_img_url)
    webscan_url = ''

    ext = nil
    if is_img_data
      ext = "."+abs_img_url.string_between_markers("data:image/",";")
    else
      ext = File.extname(u.path) if File.extname(u.path)
    end

    filename += ext if ext
    path = File.join(path, filename)

    if is_img_data
      base64_data = img_src["data:image/#{ext[1 .. -1]};base64,".length .. -1]
      img_data = Base64.decode64(base64_data)
      if @options[:img_save_mode] == 'cloud'
        webscan_url = post_img_data_to_webscan img_data, 'imgfile'
      else
        if !File.exists? path
          File.open(path, "wb") do |f|
            f.write(img_data)
          end
        end
      end
    else
      if @options[:img_save_mode] == 'cloud'
        webscan_url = post_img_url_to_webscan abs_img_url, refer
      else
        http = get_web_content abs_img_url, referer: refer
        if http[:error]
          @logger.error "download img error of #{abs_img_url} from #{refer}" if @logger
        else
          if !File.exists? path
            File.open(path, "wb") do |f|
              f.write(http[:html])
            end
          end
        end
      end
    end

    #Pathname.new(path).relative_path_from(Pathname.new(File.dirname(__FILE__)+'/../website/public')).to_s
    if  @options[:img_save_mode] == 'cloud'
      @logger.error "download img error of #{abs_img_url} from #{refer}" if @logger unless webscan_url
      webscan_url
    else
      'imgs/'+filename
    end
  end

  def get_img_path(path)
    if path.include? 'http://'
      path
    else
      "/"+path
    end
  end

  def receive_img(img, referer)
    imgs = []
    #ap img

    img_raw_src = img['src']

    %w|data-original data-src real_src|.each{ |k|
      if img[k]
        img_src = img[k]
        local_file = download_img(img_src, referer)
        imgs << {:from=>img_src, :to=>get_img_path(local_file), :type=>'string_replace', :repead=>true} if local_file #处理异步加载
        imgs << {:from=>img_raw_src, :to=>get_img_path(local_file), :type=>'string_replace', :repead=>true} if local_file #处理异步加载
      end
    }

    img_src = img['src']
    local_file = nil
    local_file = download_img(img_src, referer) if img_src
    imgs << {:from=>img_src, :to=>get_img_path(local_file), :type=>'string_replace', :repead=>true} if local_file

    imgs
  end

  #分析html(Nokogiri的node类型)中得所有img标签，下载图片到本地，然后返回替换的数组
  def receive_imgs(html,referer)
    @options ||= {:img_save_mode => 'cloud'}
    imgs = []
    if @options[:img_save_mode] != 'none'
      html.css('img').each {|img|
        receive_img(img, referer).each {|i|
          imgs << i
        }
      }
    end
    imgs
  end

  #注意：原字符串会直接替换
  def process_img_content(str)
    #替换图片
    referer = content_params[:url]
    referer = nil if referer.size<5
    cdiv = Nokogiri::HTML(content_params[:content])
    img_list = receive_imgs(cdiv, referer)
    str = content_params[:content]
    img_list.each{|r|
      while str.index(r[:from]) && (r[:from] != r[:to])
        str[r[:from]] = r[:to]
        break unless r[:repead]
      end
    }
    img_list
  end
end
