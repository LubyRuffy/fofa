root_path = File.expand_path(File.dirname(__FILE__))
require File.join(root_path, 'searchengines', 'bingsearch.rb')
#require File.join(root_path, 'searchengines', 'googlesearch.rb')
require 'logger'


class EmailDigger
  def initialize(domain,logger=nil)
    @domain = domain
    if @domain[0] == '@'
      @domain = @domain[1..-1]
    end
    @logger = logger || Logger.new(STDOUT)  #输出到控制台
  end

  def importGoogle
    #html = GoogleSearch.new.search('@'+@domain)
  end

  def importBing(api=true)
    res = []

    klass = api ? BingApiSearch : BingSearch
    results = klass.new(@logger).searchall('"@'+@domain+'"')
    results.each{|r|
      emails = _extract_email(r)
      res += emails
      yield(emails) if block_given?
    }

    results = klass.new(@logger).searchall('"_at_'+@domain+'"')
    results.each{|r|
      r = r.gsub('_at_', '@')
      r = r.gsub('(at)', '@')
      r = r.gsub(' at ', '@')
      r = r.gsub('[at]', '@')
      #puts html
      emails = _extract_email(r)
      res += emails
      yield(emails) if block_given?
    }

    res.uniq
  end

  def importEmailFormatCom
    url = "http://www.email-format.com/d/"+@domain
    html = open(url).read
    doc = Nokogiri::HTML(html)
    table = doc.css('table#domain_address_container')
    html = table[0].text if table[0]
    _extract_email(html)
  end

  def importAll(options)
    options ||= {search:1, github:1, bruteforce:1}
    res = []

    res = res + _import_from('EmailFormatCom')
    res = res + _import_from('Bing')
    #res = res + _import_from('Google')

    res.uniq
  end

  private

  def _import_from(name)
    @logger.info("Import email from #{name}...")
    emails = send("import#{name}")
    @logger.info("Found [#{emails.size}] emails ")
    emails
  end

  def _extract_email(body)
    email_name_regex = '[\w][\w\.%\+\-]*'.freeze
    emails = body.scan(/#{email_name_regex}@#{@domain}/i)
    #puts emails
    emails.uniq
  end
end

if __FILE__ == $PROGRAM_NAME
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  #emails = EmailDigger.new('tencent.com', logger).importAll
  emails = EmailDigger.new(ARGV[0] || 'sohu-inc.com').importAll
  logger.info emails
end