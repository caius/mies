#!/usr/bin/env ruby

# DEBUG
if ENV["TM_APP_IDENTIFIER"]
  # Running under TextMate
  # ARGV << "IE8_XP"
end

require "yaml"
require "fileutils"
require "uri"
require "net/https"

# TODO: use methadone or GLI

VMS = YAML.load(DATA)
# Downcase all the keys in the hash
VMS.dup.each { |k, v| VMS[k.downcase] = VMS.delete(k) }

# Rudimentary logging
# TODO: swap in Logger instance
$l = Object.new
def $l.info msg
  puts " >> #{msg}"
end
def $l.debug msg
  puts "D #{msg}" if $DEBUG
end
def $l.fatal msg
  puts "ERROR: #{msg}"
  exit 1
end

module URIFilename
  def filename
    @filename ||= path.split("/").last
  end
end

class Grabber
  def self.strategies
    @strategies ||= []
  end

  def self.strategy_for(name, urls)
    handler_class = strategies.find { |s| s.handle?(name, urls) }
    raise("can't find strategy to handle: #{name.inspect} #{urls.inspect}") unless handler_class
    handler_class.new(name, urls)
  end

  class StrategyBase
    attr_reader :name, :urls

    def self.inherited(klass)
      Grabber.strategies << klass
    end

    def self.handle?(*)
      raise NotImplementedError, "#{self} needs to override .handle?"
    end

    def initialize(name, urls)
      self.name = name
      self.urls = urls
    end

    def download
      raise NotImplementedError, "#{self.class} needs to override #download"
    end

    def extract
      raise NotImplementedError, "#{self.class} needs to override #extract"
    end

    def install
      raise NotImplementedError, "#{self.class} needs to override #install"
    end

    def cache_path
      @cache_path ||= File.expand_path("~/Library/Caches/fa-ievms/#{name}").tap {|path| FileUtils.mkdir_p(path) }
    end

    def cache_path_for(filename)
      File.join(cache_path, filename)
    end

    def store_path
      @store_path ||= File.join(STORE, name).tap {|path| FileUtils.mkdir_p(path) }
    end

    private
    attr_writer :name

    def urls= arr
      @urls = arr.map {|u| URI(u).tap {|uri| uri.extend(URIFilename) } }
    end
  end

  module DownloadFiles
    # Downloads all available urls as files to the cache path
    def download
      $l.info "(#{self.class}) downloading started for #{name.inspect}"

      urls.each do |uri|
        destination = cache_path_for(uri.filename)

        if File.exist?(destination)
          $l.info "#{File.basename(destination)} already exists!"
        else
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          # Write out file as we receive it
          File.open(destination, "w+") do |f|
            http.request_get(uri.path) do |resp|
              original_length = resp["content-length"].to_f
              remaining = original_length.to_f

              resp.read_body do |chunk|
                f.write(chunk)
                remaining -= chunk.length
                puts "#{(remaining / original_length * 100.0).round(2)}% left"
              end
            end
          end

        end
      end

      $l.info "(#{self.class}) downloading finished for #{name.inspect}"
    end
  end

  module GenericInstaller
    # Takes all available .ova packages, installs them with VBoxManage and takes an initial snapshot
    def install
      $l.info "(#{self.class}) installation started for #{name.inspect}"
      Dir[cache_path_for("*.ova")].each do |vm_archive|
        VirtualBox.manager.tap do |vm|
          vm.destroy(name)
          vm.install(vm_archive, as: name)
          vm.snapshot(name, "Initial State", description: "Original unbooted pristine state")
        end
      end
      $l.info "(#{self.class}) installation finished for #{name.inspect}"
    end
  end

  class ZipStrategy < StrategyBase
    include DownloadFiles
    include GenericInstaller

    def self.handle?(name, urls)
      urls.all? {|x| x[/zip\z/i] }
    end

    def extract
      $l.info "(#{self.class}) Extraction started"
      cmd_args = ["unzip", "-o", cache_path_for("*.zip"), "-d", cache_path]
      $l.debug cmd_args
      IO.popen(cmd_args) do |io|
        chunk = io.read
        $l.debug chunk
      end
      $l.info "(#{self.class}) Extraction finished"
    end
  end

  class OVAStrategy < StrategyBase
    include DownloadFiles
    include GenericInstaller

    def self.handle?(name, urls)
      urls.all? {|x| x[/ova\z/i] }
    end

    def extract
      # noop
    end
  end

  class RARStrategy < StrategyBase
    include DownloadFiles
    include GenericInstaller

    UNRAR = %x{which unrar}.chomp

    def self.handle?(name, urls)
      urls.first[/sfx\z/i] && urls[1..-1].all? {|x| x[/rar\z/i] }
    end

    def extract
      $l.info "(#{self.class}) extraction started for #{name.inspect}"

      Dir[cache_path_for("*.sfx")].each do | sfx |
        cmd_and_args = [
          UNRAR,
          "x", # extract
          "-o+", # overwrite
          sfx, # from
          cache_path, # to
        ]
        IO.popen(cmd_and_args) do |io|
          chunk = io.read
          $l.debug chunk
        end
      end

      $l.info "(#{self.class}) extraction finished for #{name.inspect}"
    end
  end

end

module VirtualBox
  def self.manager
    @manager ||= Manager.new
  end

  class Manager
    def install vm_archive, opts={}
      vmname = opts.fetch(:as)

      $l.info "[#{self}] Importing #{vm_archive.inspect} as #{vmname.inspect}"
      run("import", vm_archive, "--vsys", "0", "--vmname", vmname)
      $l.info "[#{self}] Finished import of #{vmname.inspect}"
    end

    def snapshot vmname, snapshot_name, opts={}
      description = opts[:description]

      $l.info "[#{self}] Snapshotting #{vmname.inspect} as #{snapshot_name.inspect}"

      command_args = ["snapshot", vmname, "take", snapshot_name]
      (command_args << "--description" << description) if description

      run(*command_args)
      $l.info "[#{self}] Finished snapshotting #{vmname.inspect}"
    end

    def list_vms
      a = run "list", "vms"
      a.split("\n").map do |line|
        name, identifier = line.split(" ")
        {name: name.tr('"', ""), identifier: identifier.tr("{}", "")}
      end
    end

    def destroy vmname
      $l.info "[#{self}] Destroying #{vmname.inspect}"
      if list_vms.find {|data| data[:name] == vmname }
        run "unregistervm", vmname, "--delete"
      else
        puts "WARN: couldn't find VM named #{vmname.inspect} to destroy"
        true
      end
      $l.info "[#{self}] Destroyed #{vmname.inspect}"
    end

    # Runs the command, printing output as it's given, and returns output as a string
    def run *args
      output = ""
      cmd_args = %w(/usr/bin/VBoxManage) | args
      $l.debug "[#{self}] run(#{cmd_args.inspect})"
      IO.popen(cmd_args) do |io|
        output << (chunk = io.read)
        $l.debug(chunk)
      end
      output
    end
  end
end

class Command
  attr_accessor :args

  def initialize(args)
    self.args = args
  end

  def flag_given? flag
    args.any? {|x| x == flag }
  end

  Error = Class.new(RuntimeError)
end

class Help < Command
  def call
    puts <<-USAGE
Downloads and installs into virtualbox the free ie virtual machines from microsoft - http://www.modern.ie/en-us/virtualization-tools#downloads

#{File.basename($0)} COMMAND [ARGS]

Available commands:
#{COMMANDS.keys.map {|x| "  #{x}"}.join("\n")}

Available VM names:
#{VMS.keys.map {|x| "  #{x}" }.join("\n")}
USAGE
    exit 2
  end
end

class Download < Command
  def name
    @name ||= args.shift
  end

  def urls
    @urls ||= VMS[name]
  end

  def call
    raise Error, "Missing valid VM identifier" unless name && VMS.keys.include?(name.downcase)

    handler = Grabber.strategy_for(name, urls)
    handler.download
  end

  def vm_exists?(name)
    VirtualBox.manager.list_vms.find {|x| x[:name] == name }
  end
end

class Install < Download
  def name
    @name ||= args.shift
  end

  def urls
    @urls ||= VMS[name]
  end

  def call
    raise Error, "Missing valid VM identifier" unless name && VMS.keys.include?(name.downcase)

    if vm_exists?(name) && !flag_given?("--force")
      raise Error, "VM exists and --force not passed"
    else
      handler = Grabber.strategy_for(name, urls)
      handler.download
      handler.extract
      handler.install
    end
  end

  def vm_exists?(name)
    VirtualBox.manager.list_vms.find {|x| x[:name] == name }
  end
end

class VirtualBoxCommand < Command
  def call
    subcommand = args.shift
    raise Error, "Missing subcommand" unless subcommand && respond_to?(subcommand)
    public_send(subcommand)
  end

  def list
    puts VirtualBox.manager.list_vms
  end

  def destroy
    identifier = args.shift
    raise Error, "Missing identifier" unless identifier
    VirtualBox.manager.destroy(identifier)
  end
end

COMMANDS = {
  "help" => Help,
  "download" => Download,
  "install" => Install,
  "virtualbox" => VirtualBoxCommand
}

begin
  args = ARGV.dup
  name= args.shift
  $c = COMMANDS[name] || Help
  $c.new(args).call
rescue Command::Error => e
  $l.fatal e.message
  Help.new(ARGV).call
end

__END__
---
IE6_XP:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE6_WinXP.ova.zip
IE8_XP:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_XP/IE8.XP.For.MacVirtualBox.ova
IE7_Vista:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part1.sfx
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part2.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part3.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part4.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part5.rar
IE8_Win7:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part1.sfx
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part2.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part3.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part4.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part5.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part6.rar
IE9_Win7:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part1.sfx
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part2.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part3.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part4.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part5.rar
IE10_Win7:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part1.sfx
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part2.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part3.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part4.rar
IE11preview_Win7:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part1.sfx
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part2.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part3.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part4.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part5.rar
IE10_Win8:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part1.sfx
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part2.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part3.rar
IE11preview_Win8.1:
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part1.sfx
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part2.rar
- https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part3.rar
