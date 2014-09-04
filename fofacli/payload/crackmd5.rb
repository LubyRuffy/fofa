require 'net/http'
require "uri"

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

module CrackMd5


  def crackmd5_aiisoo_com(md5)
    response = Net::HTTP.get_response(URI.parse("http://aiisoo.com/somd5-md5-js.html"))
    isajax = response.body.string_between_markers('isajax=', '&')
    response = Net::HTTP.post_form URI('http://aiisoo.com/somd5-index-md5.html'), isajax: isajax, md5: md5
    response.body.string_between_markers('<h1 style="display:inline;">', '</h1></p>')
  end

  def crackmd5(md5)
    @@md5list ||= File.readlines(File.join(File.expand_path(File.dirname(__FILE__)), 'md5top1k.txt')).map {|line| line.strip.split(/[ \t]/) }
    @@md5list.each{|a|
      if a.include? md5
        puts "=found from top1k"
        return a[0]
      end
    }
    md5s = [
        %w|taizhigang 30bb06c69ce06140 19790a4830bb06c69ce06140725079a1 |,
        %w|123456 49ba59abbe56e057 e10adc3949ba59abbe56e057f20f883e |,
        %w|admin 7a57a5a743894a0e 21232f297a57a5a743894a0e4a801fc3 |,
        %w|bbzhupku a8dca78843ccdaa0 88400787a8dca78843ccdaa052f76752 |,
        %w|zhangchangwei 02983b6adb65794c 1cf938c902983b6adb65794ca5c496e3 |,
        %w|84898126 f533ffbee12b5f63 ccf0ada9f533ffbee12b5f63113ddfae|,
        %w|ngaa.com.cn 1c3fc04ecc07f556 89a3bd0f1c3fc04ecc07f556c6f1d318|,
        %w|xyzzyklr d153c63b469fb8fd c1e1986ed153c63b469fb8fdb2aeb822|,
        %w|3l0t3ch 407203419b025249 f5d55247407203419b0252495d3db502|,
        %w|4emet1 45803d6b073f54b8 621fce7245803d6b073f54b8b28e1bd5|,
        %w|4r1r4nh4 724aa591c9f3b7d1 fe5e05d7724aa591c9f3b7d1fd78c877|,
        %w|[@t@k!] f422d084c4f6959e 43c915c7f422d084c4f6959ee22c269a|,
        %w|Suporte1q2w3e4r 63ab008a7d4cf203 451ee44363ab008a7d4cf203181c1172|,
        %w|V4ldr@123 dff1e21981e91cb8 6cefb425dff1e21981e91cb82fe8170f|,
        %w|zabbix 34b520afeffb37ce 5fce1b3e34b520afeffb37ce08c7cd66|,
        %w|KKtalk ee8f15e428634a7a 9919e799ee8f15e428634a7ad6fab3c4|,
        %w|suming8888 0d09e5dc44b4e169 c2bf23e30d09e5dc44b4e1693ffe5618|,

    ]

    md5 = md5.downcase
    return '' if md5=='d41d8cd98f00b204e9800998ecf8427e' || md5=='8f00b204e9800998'
    md5s.each{|a|
      return a[0] if a.include? md5
    }
    crackmd5_aiisoo_com(md5)
  end
end

if __FILE__==$0
  include CrackMd5
  puts crackmd5('2dbf773963946e104d50d1084b0b864e')
end