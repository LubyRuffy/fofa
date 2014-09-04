#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

clibase = __FILE__
while File.symlink?(clibase)
  clibase = File.expand_path(File.readlink(clibase), File.dirname(clibase))
end

$:.unshift(File.expand_path(File.join(File.dirname(clibase), 'lib')))
.unshift(File.expand_path(File.join(File.dirname(clibase))))
.unshift(File.expand_path(File.join(File.dirname(clibase), 'gem_lib')))

class Fofacli
  def initialize(args)
    @args = {}

    @args[:module_name] = args.shift # First argument should be the module name
    @args[:mode] = args.pop || 's' # Last argument should be the mode
    @args[:params] = {"showall" => 'true'}
    args.each{|p|
      ps = p.split('=')
      k = ps.shift
      v = ps.join('=')
      @args[:params][k] = v
    } # Whatever is in the middle should be the params
  end

  def usage(str = nil, extra = nil)
    $stdout.puts "Usage: #{$0} <exploit_name> [option=value] [mode]"
    $stdout.puts "Error: #{str}\n\n" if str
    $stdout.puts extra + "\n" if extra
    $stdout.puts
  end

  def dump_module_list
    $stdout.puts "[*] Please wait while we load the module tree..."
    $stdout.puts "===== exploit list ====="
    #todo: load exploits in exploits/*.rb
    ext = ''
    Dir["exploits/*.rb"].each do |filename|
      ext << File.basename(filename, '.rb')
      ext << "\n"
    end
    ext
  end

  def dump_modes
    ext = %Q{===== Mode list =====
h\t:\tshow mode list
i\t:\tshow module infomation
s\t:\tscan vulnerability
e\t:\texploit vulnerability(in development)}
    ext
  end

  def dump_options
    ext = %Q{===== Option list =====
showall\t:\tshow all result even it's not vulnerable, default true
fofaquery\t:\tuser defined fofa query string, if not supplied, then use exploit build-in
hostinfo\t:\tcheck only one host, format like host:port}
    ext
  end

  def engage_mode(modules)
    case @args[:mode].downcase
      when 'h'
        ext = dump_modes
        usage(nil, ext)
        $stdout.puts dump_options
      when 'i'
        show_module_info(modules)
      when 's'
        execute_module(modules)
      when 'e'
        execute_module(modules, 'exploit')
      else
        ext = dump_modes
        usage("Invalid mode #{@args[:mode]}", ext)
    end
  end


  def show_module_info(modules)
    modules.new.info.each{|k,v|
      $stdout.printf("%-20s\t:\t%s\n", k, v.to_s ) if k!="ScanSteps"
    }
  end

  def init_modules
    $stdout.puts "[*] Initializing modules..."
    module_name = @args[:module_name]
    exploits_path = File.expand_path(File.join(File.dirname(__FILE__), 'exploits', module_name+".rb"))
    if !File.exist? exploits_path
      $stdout.puts "[*] ERROR: not found module name as #{module_name}: #{exploits_path}"
      ext = dump_module_list
      usage(nil, ext)
      exit
    end
    require exploits_path
    return FofaExploits
  end

  def execute_module(m, mod='scan')
    fe = m.new
    #p @args[:params]
    if @args[:params]["hostinfo"]
      if mod=='scan'
        vulnerable = fe.vulnerable(@args[:params]["hostinfo"])
        if vulnerable
          puts "#{@args[:params]["hostinfo"]} : vulnerable"
        else
          puts "#{@args[:params]["hostinfo"]} : -"
        end
      else
        puts "#{@args[:params]["hostinfo"]} : #{fe.exploit(@args[:params]["hostinfo"])}"
      end
    elsif @args[:params]["fofaquery"] || fe.info['FofaQuery']
      require 'net/http'
      require 'json'
      require 'base64'
      require 'cgi'
      require 'yaml'

      cfg_file = File.join(File.expand_path(File.dirname(__FILE__)), 'conf/fofa.yml')
      unless File.exist? cfg_file
        $stderr.puts "[ERROR] no config file exists: #{cfg_file}"
        exit -1
      end
      fofacfg = YAML::load( File.open(cfg_file) )
      #puts fofacfg

      fofaquery = @args[:params]["fofaquery"] || fe.info['FofaQuery']
      uri = URI('http://fofa.so/api/result?qbase64='+CGI.escape(Base64.encode64(fofaquery))+'&key='+fofacfg['key']+'&email='+fofacfg['email'] )
      res = Net::HTTP.get_response(uri)
      info = JSON.parse(res.body)
      if info['error']
        $stderr.puts "[ERROR] receive fofa results failed: #{info['error']}"
      else
        results = info['results']
        if results.size>0
          require 'thread/pool'
          @p = Thread.pool(10)
          results.each{|h|
            @p.process(h,mod,m,@args[:params]["showall"]) {|h,mod,m,showall|
              fexploit = m.new
              if mod=='scan'
                vulnerable = fexploit.vulnerable(h)
                if vulnerable
                  puts "#{h} : vulnerable"
                elsif showall=='true' || showall=='1'
                  puts "#{h} : -"
                end
              else
                puts "#{h} : #{fexploit.exploit(h)}"
              end
            }
          }
          @p.join
          @p.shutdown
        else
          $stderr.puts "[WARNING] fofa returns host < 1"
        end
      end

    else
      puts "no target to scan, set hostinfo=127.0.0.1:80 or fofaquery='body=\"123\"'"
      exit
    end
  end

  def run!

    if @args[:module_name].nil? || @args[:module_name] == "-h"
      usage()
      $stdout.puts dump_module_list
      $stdout.puts dump_options
      $stdout.puts dump_modes
      exit
    end

    mod = init_modules

    engage_mode(mod)
    $stdout.puts
  end
end

if __FILE__ == $PROGRAM_NAME
  cli = Fofacli.new(ARGV)
  cli.run!
end