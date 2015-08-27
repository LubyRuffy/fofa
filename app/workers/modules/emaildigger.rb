root_path = File.expand_path(File.dirname(__FILE__))
require File.join(root_path, 'searchengines', 'bingsearch.rb')
require File.join(root_path, 'searchengines', 'googlesearch.rb')

class EmailDigger
  def initialize(domain)
    @domain = domain
  end

  def importGoogle
    html = GoogleSearch.new.search('@'+@domain)
  end

  def importBing
    res = []

    results = BingSearch.searchall('"@'+@domain+'"')
    results.each{|r|
      res << _extract_email(r)
    }

    results = BingSearch.searchall('"_at_'+@domain+'"')
    results.each{|r|
      r = r.gsub('_at_', '@')
      r = r.gsub('(at)', '@')
      r = r.gsub(' at ', '@')
      #puts html
      res << _extract_email(r)
    }

    res.uniq
  end

  def importEmailFormatCom
    url = "http://www.email-format.com/d/"+@domain
    html = open(url).read
    doc = Nokogiri::HTML(html)
    html = doc.css('table#domain_address_container')[0].text
    _extract_email(html)
  end

  def importAll()
    res = []
    res = res + importEmailFormatCom
    res = res + importBing
    #importGoogle
    res.uniq
  end

  private
  def _extract_email(body)
    email_name_regex = '[\w][\w\.%\+\-]*'.freeze
    emails = body.scan(/#{email_name_regex}@#{@domain}/i)
    #puts emails
    emails.uniq
  end
end

if __FILE__ == $PROGRAM_NAME
  emails = EmailDigger.new('tencent.com').importAll
  #emails = EmailDigger.new('sohu-inc.com').importAll
  puts emails
end