#!/usr/bin/env ruby

clibase = __FILE__
while File.symlink?(clibase)
  clibase = File.expand_path(File.readlink(clibase), File.dirname(clibase))
end

$:.unshift(File.expand_path(File.join(File.dirname(clibase), 'lib')))

class Fofacli
  def initialize(args)
    @args = {}

    @args[:module_name] = args.shift # First argument should be the module name
    @args[:mode] = args.pop || 'h' # Last argument should be the mode
    @args[:params] = args # Whatever is in the middle should be the params
  end

  def usage(str = nil, extra = nil)
    $stdout.puts "Usage: #{$0} <exploit_name> <option=value> [mode]"
    $stdout.puts "Error: #{str}\n\n" if str
    $stdout.puts extra + "\n" if extra
    $stdout.puts
  end

  def dump_module_list
    $stdout.puts "[*] Please wait while we load the module tree..."
    #todo: load exploits in exploits/*.rb
    ext = ''
    Dir.each { |x| x.name }
    ext <<
    ext << "\n"
    ext
  end

  def init_modules
    $stdout.puts "[*] Initializing modules..."
    module_name = @args[:module_name]
    modules[:module] =
  end

  def run!
    if @args[:module_name] == "-h"
      usage()
      exit
    end

    if @args[:module_name].nil?
      ext = dump_module_list
      usage(nil, ext)
      exit
    end

    modules = init_modules

    if modules[:module].nil?
      usage("Invalid module: #{@args[:module_name]}")
      exit
    end

    # Process special var/val pairs...
    Msf::Ui::Common.process_cli_arguments(@framework, @args[:params])

    engage_mode(modules)
    $stdout.puts
  end
end

if __FILE__ == $PROGRAM_NAME
  cli = Fofacli.new(ARGV)
  cli.run!
end