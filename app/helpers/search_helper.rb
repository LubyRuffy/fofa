# -*- encoding : utf-8 -*-

class String
  def and(a)
    #"( #{self} && #{a} )"
    "( #{self} && #{a} )"
  end

  def or(a)
    "( #{self} || #{a} )"
  end

  def query_escape
    v = self
    tr = %w'" + & | > < ! ( ) { } [ ] ^ ~ */' # = - ? : "
    v = v.gsub('\\', "\\\\\\")
    tr.each{|t|
      if v.include?(t)
        v = v.gsub(t, '\\'+t)
      end

    }
    v
  end
end


module SearchHelper
  @@geoip = nil

  def get_country_of_ip(ip)
    unless @@geoip
      require 'geoip'
      geodata = File.join(Rails.root, 'tools', 'data' , 'GeoIP.dat')
      @@geoip = GeoIP.new(geodata)
    end
    @@geoip.country(ip).to_hash[:country_code2].downcase
  end


  def get_http_info_from_db_or_net(url)
    return nil unless url
    http_info = nil
    host=hostinfo_of_url(url)
    #try to get from db
    doc = Subdomain.es_get(host)
    if doc
      http_info = doc['_source']
    else
      http_info ||= realtimeprocess(host)
    end
    http_info
  end

  def check_info(app, http_info)
    #puts "checking #{app.product}"
    AppProcessor.parse(app.rule, http_info)
  end

  def check_app(url,return_all=true,onlyapp=nil)
    apps = []
    http_info = get_http_info_from_db_or_net(url)
    if http_info
      rules = Rule.published
      rules = rules.select{|r| onlyapp==r.product} if onlyapp
      rules.each{ |app|
        if check_info(app, http_info)
          if return_all
            apps << app.product
          else
            return app.product
          end
        end
      }
    end
    return_all ? apps.uniq : nil
  end

  def get_cms
    # 大于号>也好转义
    return [
      ['phpshe','2014-07-16','http://www.phpshe.com','body="phpshe"'],
      ['华天动力OA(OA8000)','2014-07-16','http://www.oa8000.com','body="/OAapp/WebObjects/OAapp.woa"'],
      ['ThinkSAAS','2014-07-16','http://www.thinksaas.cn','body="/app/home/skins/default/style.css"'],
      ['e-tiller','2014-07-16','http://www.e-tiller.com','body="reader/view_abstract.aspx"'],
      ['mongodb','2014-07-11','http://www.mongodb.org','body="<a href=\"/_replSet\">Replica set status</a></p>"'],
      ['易瑞授权访问系统', '2014-07-09', 'http://www.infcn.com.cn/iras/752.jhtml', 'body="/authjsp/login.jsp" || body="FE0174BB-F093-42AF-AB20-7EC621D10488"'],
      ['fangmail', '2014-07-09', 'http://www.fangmail.net/', 'body="/fangmail/default/css/em_css.css"'],
      ['腾讯企业邮箱', '2014-07-09', 'http://exmail.qq.com/', 'body="/cgi-bin/getinvestigate?flowid="'],
      ['通达0A', '2014-07-09', 'http://www.tongda2000.com/', 'body="<link rel=\"shortcut icon\" href=\"/images/tongda.ico\" />" || (body="OA提示：不能登录OA" && body="紧急通知：今日10点停电") || body="Office Anywhere 2013"'],
      ['jira', '2014-07-08', 'https://www.atlassian.com/software/jira', 'body="atl.dashboard" && header="atlassian" && body="jira"'],
      ['fisheye', '2014-07-08', 'https://www.atlassian.com/software/fisheye/overview', 'header="Set-Cookie: FESESSIONID" || body="fisheye-16.ico"'],
      ['elasticsearch', '2014-07-07', 'http://www.elasticsearch.org/', '(header="application/json" && body="build_hash") || body="You Know, for Search"'],
      ['MDaemon', '2014-07-07', 'http://www.altn.com/Products/MDaemon-Email-Server-Windows/', 'body="/WorldClient.dll?View=Main"'],
      ['ThinkPHP', '2014-07-03', 'http://www.thinkphp.cn', 'header="thinkphp"'],
      ['OA(a8/seeyon/ufida)', '2014-07-01', 'http://yongyougd.com/productsview88.html', 'body="/seeyon/USER-DATA/IMAGES/LOGIN/login.gif"'],
      ['yongyoufe', '2014-07-01', 'http://yongyougd.com/productsview88.html', 'title="FE协作" || (body="V_show" && body="V_hedden")'],
      ['Zen Cart', '2013-12-18', 'http://www.zen-cart.com/', 'body="shopping cart program by Zen Cart" || header="Set-Cookie: zenid="'],
      ['iWebShop', '2013-12-18', 'http://www.jooyea.cn/', '(body="Powered by" && body="iWebShop") || header="iweb_safecode"'],
      ['DouPHP', '2013-12-18', 'http://www.douco.com/', 'body="Powered by DouPHP" || (body="controlBase" && body="indexLeft" && body="recommendProduct")'],
      ['twcms', '2013-12-18', 'http://www.twcms.cn/', 'body="/twcms/theme/" && body="/css/global.css"'],
      ['Cicro', '2013-12-03', 'http://www.cicro.com/', '(body="Cicro" && body="CWS") || body="content=\"Cicro" || body="index.files/cicro_userdefine.css" || (body="structure/index" && body="window.location.href=")'],
      ['SiteServer', '2013-11-29', 'http://www.siteserver.cn/', '(body="Powered by" && body="http://www.siteserver.cn" && body="SiteServer CMS") || title="Powered by SiteServer CMS" || body="T_系统首页模板" || (body="siteserver" && body="sitefiles")'],
      ['Joomla', '2013-11-28', 'http://www.Joomla.org', 'body="content=\"Joomla" || (body="/media/system/js/core.js" && body="/media/system/js/mootools-core.js")'],
      ['vBulletin', '2013-11-28', 'http://www.vbulletin.com', 'body="content=\"vBulletin" || body="vbulletin-core.js" || body="Powered by vBulletin&trade;"'],
      ['phpbb', '2013-11-28', 'http://www.phpbb.com/','header="Set-Cookie: phpbb3_" || header="HttpOnly, phpbb3_" || (body="&copy;" && body="http://www.longluntan.com/zh/phpbb/" && body="phpBB") || body="phpBB Group\" /\>" || body="START QUICK HACK - phpBB Statistics MOD"'],
      ['HDWiki', '2013-11-26', 'http://kaiyuan.hudong.com/','title="powered by hdwiki!" || body="content=\"HDWiki" || body="http://kaiyuan.hudong.com?hf=hdwiki_copyright_kaiyuan" || header="hd_sid="'],
      ['kesionCMS', '2013-11-25', 'http://www.kesion.com/','body="/ks_inc/common.js" || body="publish by KesionCMS"'],
      ['CMSTop', '2013-11-23', 'http://www.cmstop.com/','body="/css/cmstop-common.css" || body="/js/cmstop-common.js" || body="cmstop-list-text.css" || body="<a class=\"poweredby\" href=\"http://www.cmstop.com\""'],
      ['ESPCMS', '2013-11-23', 'http://www.ecisp.cn/','title="Powered by ESPCMS" || body="Powered by ESPCMS" || (body="infolist_fff" && body="/templates/default/style/tempates_div.css")'],
      ['74cms', '2013-11-23', 'http://www.74cms.com/','(body="content=\"74cms.com" || body="content=\"骑士CMS" || body="Powered by <a href=\"http://www.74cms.com/\"" || (body="/templates/default/css/common.css" && body="selectjobscategory"))'],
      ['Foosun', '2013-11-21', 'http://www.foosun.net/','body="Created by DotNetCMS" || body="For Foosun" || body="Powered by www.Foosun.net,Products:Foosun Content Manage system"'],
      ['PhpCMS', '2013-11-21', 'http://www.phpcms.com/','(body="Powered by" && body="http://www.phpcms.cn") || body="content=\"Phpcms" || body="Powered by Phpcms"'],
      ['Hanweb', '2013-11-21', 'http://www.hanweb.com/','body="Produced By 大汉网络" || body="<a href=\'http://www.hanweb.com\' style=\'display:none\'>" || body="<meta name=\'Generator\' content=\'大汉版通\'>" || body="<meta name=\'Author\' content=\'大汉网络\'>" || body="/jcms_files/jcms"'],
      ['Drupal', '2013-11-21', 'http://www.drupal.org/','header="X-Generator: Drupal" || body="content=\"Drupal" || body="jQuery.extend(Drupal.settings" || (body="/sites/default/files/" && body="/sites/all/modules/" && body="/sites/all/themes/")'],
      ['phpwind', '2013-11-19', 'http://www.phpwind.net/','title="Powered by phpwind" || body="content=\"phpwind"'],
      ['discuz', '2013-11-19', 'http://www.discuz.net/','title="Powered by Discuz" || body="content=\"Discuz" || (body="discuz_uid" && body="portal.php?mod=view")'],
      ['vBulletin', '2013-11-19', 'http://www.vBulletin.com/','title="Powered by vBulletin" || body="content=\"vBulletin" || (header=bbsessionhash && header=bblastvisit)'],
      ['cmseasy', '2013-11-19', 'http://www.cmseasy.cn/','title="Powered by CmsEasy" || header="http://www.cmseasy.cn/service_1.html" || body="content=\"CmsEasy"'],
      ['wordpress', '2013-11-19', 'http://www.wordpress.com/','( body="content=\"WordPress" || (header="X-Pingback" && header="/xmlrpc.php" && body="/wp-includes/" ) )'],
      ['DedeCMS', '2013-11-19', 'http://www.dedecms.com/','(body="Power by DedeCms" || (body="Powered by" && body="http://www.dedecms.com/" && body="DedeCMS") || body="/templets/default/style/dedecms.css")'],
      ['ECShop', '2013-11-19', 'http://www.ecshop.com/','title="Powered by ECShop" || header="ECS_ID" || body="content=\"ECSHOP" || body="/api/cron.php"'],
      ['ASPCMS', '2013-11-19', 'http://www.aspcms.com/','title="Powered by ASPCMS" || body="content=\"ASPCMS" || body="/inc/AspCms_AdvJs.asp"'],
      ['MetInfo', '2013-11-19', 'http://www.metinfo.com/','title="Powered by MetInfo" || body="content=\"MetInfo" || body="powered_by_metinfo" || body="/images/css/metinfo.css"'],
      ['PageAdmin', '2013-11-19', 'http://www.pageadmin.net/','title="Powered by PageAdmin" || body="content=\"PageAdmin" || body="Powered by <a href=\'http://www.pageadmin.net\'"'],
      ['Npoint', '2013-11-19', '#', 'title="Powered by Npoint"'],
      ['小蚂蚁', '2013-11-19', 'http://www.xiaomayi.co/', 'title="Powered by 小蚂蚁地方门户网站系统" || header="AntXiaouserslogin" || body="/Template/Ant/Css/AntHomeComm.css"'],
      ['捷点JCMS', '2013-11-19', 'http://www.jcms.com.cn/', 'body="Publish By JCms2010"'],
      ['帝国EmpireCMS', '2013-11-19', 'http://www.phome.net/', 'title="Powered by EmpireCMS"'],
      ['phpMyadmin', '2013-11-19', 'http://www.phpmyadmin.net/', 'header="Set-Cookie: phpMyAdmin=" || title="phpMyAdmin " || body="pma_password"'],
      ['JEECMS', '2013-11-19', 'http://www.jeecms.com/', 'title="Powered by JEECMS" || (body="Powered by" && body="http://www.jeecms.com" && body="JEECMS")'],
    ]
  end

  def get_frameworks
    return [
      ['django', '2013-11-28', 'http://www.djangoproject.com/', 'header="django"'],
      ['rails', '2013-11-28', 'http://www.rubyonrails.org/', 'header="Phusion" || header="Webrick" || header="rails"'],
      ['struts', '2013-11-28', 'http://struts.apache.org/', '(header="Apache-Coyote" || header="JSESSIONID") && (body=".do\"" || body=".action\"")'],
    ]
  end
  
  def get_cloudsec
    return [
      ['baidu_yunjiasu', '2014-07-07', 'http://yunjiasu.baidu.com/', 'header="X-Server" && header="fhl"'],
      ['Cloudflare', '2013-11-25', 'http://www.cloudflare.com/', 'header="cloudflare-nginx"'],
      ['Incapsula', '2013-11-25', 'http://www.Incapsula.com/', 'header="X-Cdn: Incapsula"'],
      ['jiasule', '2013-11-25', 'http://jiasule.baidu.com', 'header!="server: " && header="X-Cache:" && header="Connection: keep-alive"'],
      ['360_wangzhanweishi', '2013-11-25', 'http://wangzhan.360.cn/', 'header="360wzb"'],
      ['anquanbao', '2013-11-25', 'http://www.anquanbao.com/', 'header="X-Powered-By-Anquanbao"'],

    ]
  end

  def get_cdn
    return [
      ['蓝讯', '2013-11-25', 'http://www.chinacache.com/', 'header="Powered-By-ChinaCache"'],
      ['网宿', '2013-11-25', 'http://www.chinanetcenter.com/', 'header="Cdn Cache Server" || header="WS CDN Server"'],
      ['帝联', '2013-11-25', 'http://www.dnion.com/', 'header="Server: DNION" || header="fastcdn.com"'],
      ['快网', '2013-11-25', 'http://www.fastweb.com.cn/', 'header="Fw-Via: "'],
      ['72cdn?', '2013-11-25', 'http://www.72cdn.com/', 'header=".72cdn.com"'],
      ['Webluker', '2013-11-25', 'http://www.webluker.com/', 'header="Webluker-Edge"'],
      ['西部数码', '2013-11-29', 'http://www.west263.com/', 'header="WT263CDN"'],
    ]
  end

  def get_base_librarys
    return [
      ['google-analytics', '2013-11-26', 'http://www.google.com/analytics', 'body="google-analytics.com/ga.js"'],
      ['cnzz', '2013-11-26', 'http://www.cnzz.com', 'body="cnzz.com/stat.php?id="'],
      ['jQuery', '2013-11-24', 'http://jquery.com/', 'body="jquery"'],
      ['bootstrap', '2013-11-24', 'http://getbootstrap.com/', 'body="bootstrap.css" || body="bootstrap.min.css"'],
    ]
  end

  def get_servers
    return [
      ['IIS', '2014-07-09', '-', 'header="Microsoft-IIS" || header="X-Powered-By: WAF/2.0"'],
      ['nginx', '2014-07-09', '-', 'header="nginx"'],
      ['Tomcat', '2014-07-09', '-', 'header="Apache-Coyote"'],
      ['Apache', '2014-07-09', '-', 'header="Apache" && header!="Apache-Coyote"'],
      ['TEngine', '2014-07-09', '-', 'header="Tengine"'],
      ['IBM_HTTP_Server', '2014-07-09', '-', 'header="IBM_HTTP_Server"'],
      ['GSE', '2014-07-09', '-', 'header="Server: GSE"'],
      ['LiteSpeed', '2014-07-09', '-', 'header="LiteSpeed"'],
      ['Microsoft-HTTPAPI', '2014-07-09', '-', 'header="Microsoft-HTTPAPI"'],#sqlserver2008
      ['ngx_openresty', '2014-07-09', '-', 'header="ngx_openresty"'],
      ['Zeus', '2014-07-09', '-', 'header="Server: Zeus"'],
      ['Resin', '2014-07-09', '-', 'header="Resin"'],
      ['Netscape-Enterprise', '2014-07-09', '-', 'header="Netscape-Enterprise"'],
      ['Phusion', '2014-07-09', '-', 'header="Phusion"'],
      ['webrick', '2014-07-09', '-', 'header="webrick"'],
      ['Jetty', '2014-07-09', '-', 'header="Server: Jetty"'],
      ['Sun-ONE-Web-Server', '2014-07-09', '-', 'header="Sun-ONE-Web-Server"'],
      ['Oracle-Application-Server', '2014-07-09', '-', 'header="Oracle-Application-Server"'],
      ['JBoss', '2014-07-09', '-', 'header="Server: JBoss"'],
      #['header="Server: Oversee"'],
      #['header="Server: BSM"'],
      #['header="Server: JDWS"'],
      #['header="Server: Youboy-WS"'],
      #['header="Server: PWS"'],
      #['header="Server: Tomcat"'], Server: Tomcat X-Powered-By: WAF/2.0 这个指纹是安全狗
    ]
  end





  require 'parslet'

  class QueryParser < Parslet::Parser  
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:left_parenthesis) { str('(') }
    rule(:right_parenthesis) { str(')') }

    # Comparisons
    rule(:fulleq) { str('==') } #完整匹配
    rule(:eq) { str('=') }
    rule(:not_eq) { str('!=') }
    rule(:matches) { str('~=') }
    rule(:lt) { str('<') }
    rule(:lteq) { str('<=') }
    rule(:gt) { str('>') }
    rule(:gteq) { str('>=') }

    # Operators
    rule(:and_operator) { str('&&') }
    rule(:or_operator) { str('||') }

    # Operand
    rule(:null) { str("null").as(:nil) }
    rule(:boolean) { str("true").as(:boolean) | str("false").as(:boolean) }
    rule(:number) { match('[-+]?([0-9]*\.)?[0-9]').repeat(1).as(:number) }
    rule(:double_quote_string) do
      str('"') >>
      (
        (str('\\') >> any) |
        (str('"').absent? >> any)
      ).repeat.as(:string) >>
      str('"')
    end
    rule(:literal) { match('[a-zA-Z0-9\-_]').repeat(1) }
    rule(:identifier) { null | boolean | number | double_quote_string | literal.as(:string) }

    # Grammar
    rule(:compare_fulleq) { (literal.as(:left) >> space? >> fulleq >> space? >> identifier.as(:right)).as(:fulleq) }
    rule(:compare_eq) { (literal.as(:left) >> space? >> eq >> space? >> identifier.as(:right)).as(:eq) }
    rule(:compare_not_eq) { (literal.as(:left) >> space? >> not_eq >> space? >> identifier.as(:right)).as(:not_eq) }
    rule(:compare_matches) { (literal.as(:left) >> space? >> matches >> space? >> identifier.as(:right)).as(:matches) }
    rule(:compare_lt) { (literal.as(:left) >> space? >> lt >> space? >> identifier.as(:right)).as(:lt) }
    rule(:compare_lteq) { (literal.as(:left) >> space? >> lteq >> space? >> identifier.as(:right)).as(:lteq) }
    rule(:compare_gt) { (literal.as(:left) >> space? >> gt >> space? >> identifier.as(:right)).as(:gt) }
    rule(:compare_gteq) { (literal.as(:left) >> space? >> gteq >> space? >> identifier.as(:right)).as(:gteq) }

    rule(:compare) { compare_fulleq | compare_eq | compare_not_eq | compare_matches | compare_lteq | compare_lt | compare_gteq | compare_gt }

    rule(:primary) { left_parenthesis >> space? >> or_operation >> space? >> right_parenthesis | compare }
    rule(:and_operation) { (primary.as(:left) >> space? >> and_operator >> space? >> and_operation.as(:right)).as(:and) | primary }
    rule(:or_operation) { (and_operation.as(:left) >> space? >> or_operator >> space? >> or_operation.as(:right)).as(:or) | and_operation }

    root :or_operation
  end

  #生成query_string 格式，
=begin
  class ElasticProcessor
    def self.parse(query)
      instance = self.new()
      instance.parse(query)
    end

    def parse(query)
      begin
        ast = QueryParser.new.parse(query)
        process(ast)
      rescue Parslet::ParseFailed => error
        raise Parslet::ParseFailed, error
        #pp "ParseError" + error.inspect
      end
    end

    def process(ast)
      operation = ast.keys.first
      self.send("process_#{operation}".to_sym, ast[operation]) if self.respond_to?("process_#{operation}".to_sym, true)
    end

    protected

    def check_column!(value)
      indexed = %w|title header body host ip ipstr domain lastupdatetime|
      unless indexed.include?(value)
        source = Parslet::Source.new(value.to_s)
        cause = Parslet::Cause.new('Column not found', source, value.offset, [])
        raise Parslet::ParseFailed.new('Column not found', cause)
      end
      value = "ipstr" if value=="ip"
      value
    end
    def process_and(ast)
      process(ast[:left]).and(process(ast[:right]))
    end

    def process_or(ast)
      process(ast[:left]).or(process(ast[:right]))
    end

    def process_eq(ast)
      field = check_column!(ast[:left])
      "#{field}:(*#{parse_value(ast[:right]).query_escape}*)"
      #table[ast[:left].to_sym].eq(parse_value(ast[:right]))
    end

    def process_not_eq(ast)
      field = check_column!(ast[:left])
      "-#{field}:(*#{parse_value(ast[:right]).query_escape}*)"
      #table[ast[:left].to_sym].not_eq(parse_value(ast[:right]))
    end

    def process_matches(ast)
      field = check_column!(ast[:left])
      table[ast[:left].to_sym].matches(parse_value(ast[:right]))
    end

    def process_lt(ast)
      check_column!(ast[:left])
      table[ast[:left].to_sym].lt(parse_value(ast[:right]))
    end

    def process_lteq(ast)
      check_column!(ast[:left])
      table[ast[:left].to_sym].lteq(parse_value(ast[:right]))
    end

    def process_gt(ast)
      field = check_column!(ast[:left])
      "#{field}:([\"#{parse_value(ast[:right]).query_escape}\" TO *])"
    end

    def process_gteq(ast)
      check_column!(ast[:left])
      table[ast[:left].to_sym].gteq(parse_value(ast[:right]))
    end

    def parse_value(value)
      type = value.keys.first
      case type
        when :nil
          return nil
        when :boolean
          return value[:boolean] == "true"
        else
          return value[type].to_s
      end
    end
  end
=end

  class ElasticProcessorBool
    def self.parse(query)
      instance = self.new()
      instance.parse(query)
    end

    def parse(query)
      @string_query_fields = ['body', 'header_ok']
      begin
        ast = QueryParser.new.parse(query)
        v = process(ast)
        unless v.include?('bool')
          v = %Q|{"bool":{"must":[#{v}]}}|
        end
        v

      rescue Parslet::ParseFailed => error
        raise Parslet::ParseFailed, error
        #pp "ParseError" + error.inspect
      end
    end

    def process(ast)
      operation = ast.keys.first
      self.send("process_#{operation}".to_sym, ast[operation]) if self.respond_to?("process_#{operation}".to_sym, true)

    end

    protected

    def check_column!(value)
      indexed = %w|title header header_ok body host ip ipstr domain lastupdatetime|
      unless indexed.include?(value)
        source = Parslet::Source.new(value.to_s)
        cause = Parslet::Cause.new('Column not found', source, value.offset, [])
        raise Parslet::ParseFailed.new('Column not found', cause)
      end
      value = "ipstr" if value=="ip"
      value = "header_ok" if value=="header"
      value
    end

    def process_and(ast)
      lv = process(ast[:left])
      rv = process(ast[:right])
      %Q|{"bool":{"must":[#{lv},#{rv}]}}|
    end

    def process_or(ast)
      lv = process(ast[:left])
      rv = process(ast[:right])
      %Q|{"bool":{"should":[#{lv},#{rv}]}}|
    end

    def process_eq(ast)
      field = check_column!(ast[:left])
      "#{field}:(*#{parse_value(ast[:right]).query_escape}*)"
      field = check_column!(ast[:left])
      if @string_query_fields.include?(field)
        %Q|{"query_string":{"query":"#{field}:(\\"#{parse_value(ast[:right]).query_escape}\\")"}}|
      else
        %Q|{"wildcard":{"#{field}":"*#{parse_value(ast[:right]).query_escape}*"}}|
      end
    end

    def process_fulleq(ast)
      field = check_column!(ast[:left])
      if @string_query_fields.include?(field)
        %Q|{"query_string":{"query":"#{field}:(\\"#{parse_value(ast[:right]).query_escape}\\")"}}|
      else
        %Q|{"term":{"#{field}":"#{parse_value(ast[:right]).query_escape}"}}|
      end
    end

    def process_not_eq(ast)
      field = check_column!(ast[:left])
      v = ''
      if @string_query_fields.include?(field)
        v = %Q|{"query_string":{"query":"#{field}:(\\"#{parse_value(ast[:right]).query_escape}\\")"}}|
      else
        v = %Q|{"wildcard":{"#{field}":"*#{parse_value(ast[:right]).query_escape}*"}}|
      end
      %Q|{"bool":{"must_not":[#{v}]}}|
    end

    def process_matches(ast)
      field = check_column!(ast[:left])
      table[ast[:left].to_sym].matches(parse_value(ast[:right]))
    end

    def process_lt(ast)
      check_column!(ast[:left])
      table[ast[:left].to_sym].lt(parse_value(ast[:right]))
    end

    def process_lteq(ast)
      check_column!(ast[:left])
      table[ast[:left].to_sym].lteq(parse_value(ast[:right]))
    end

    def process_gt(ast)
      field = check_column!(ast[:left])
      "#{field}:([\"#{parse_value(ast[:right]).query_escape}\" TO *])"
    end

    def process_gteq(ast)
      check_column!(ast[:left])
      table[ast[:left].to_sym].gteq(parse_value(ast[:right]))
    end

    def parse_value(value)
      type = value.keys.first
      case type
        when :nil
          return nil
        when :boolean
          return value[:boolean] == "true"
        else
          return value[type].to_s
      end
    end
  end


  #实际检查
  class AppProcessor
    attr_accessor :http
    def self.parse(query, http)
      instance = self.new()
      instance.parse(query, http)
    end

    def parse(query, http)
      begin
        @http = http
        ast = QueryParser.new.parse(query)
        process(ast)
      rescue Parslet::ParseFailed => error
        raise Parslet::ParseFailed, error
        #pp "ParseError" + error.inspect
      end
    end

    def process(ast)
      operation = ast.keys.first
      self.send("process_#{operation}".to_sym, ast[operation]) if self.respond_to?("process_#{operation}".to_sym, true)
    end

    protected

    def check_column!(value)
      indexed = %w|title header body host ip|
      unless indexed.include?(value)
        source = Parslet::Source.new(value.to_s)
        cause = Parslet::Cause.new('Column not found', source, value.offset, [])
        raise Parslet::ParseFailed.new('Column not found', cause)
      end
    end
    def process_and(ast)
      process(ast[:left]) && process(ast[:right])
    end

    def process_or(ast)
      process(ast[:left]) || process(ast[:right])
    end

    def process_eq(ast)
      check_column!(ast[:left])
      value=parse_value(ast[:right])
      value.gsub! '\"', '"'
      @http[ast[:left].to_s].downcase.include?  value.downcase
    end

    def process_not_eq(ast)
      check_column!(ast[:left])
      value=parse_value(ast[:right])
      value.gsub! '\"', '"'
      !@http[ast[:left].to_s].downcase.include?  value.downcase
    end

    def parse_value(value)
      type = value.keys.first
      case type
        when :nil
          return nil
        when :boolean
          return value[:boolean] == "true"
        else
          return value[type].to_s
      end
    end
  end



end
