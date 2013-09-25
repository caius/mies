#!/usr/bin/env ruby

# DEBUG
if ENV["TM_APP_IDENTIFIER"]
  # Running under TextMate
  ARGV << "IE8_XP"
end

require "yaml"
require "fileutils"
require "uri"
require "net/https"

# TODO: use methadone or GLI

STORE = File.expand_path("~/.fa-ievms")
FileUtils.mkdir_p(STORE)

VMS = YAML.load(DATA)
# Downcase all the keys in the hash
VMS.dup.each { |k, v| VMS[k.downcase] = VMS.delete(k) }

$l = Object.new
def $l.info msg
  puts " >> #{msg}"
end

def usage
  puts <<-USAGE
#{$0} [VM name]

Available VM names:
  - all
#{VMS.keys.map {|x| "  - #{x}" }.join("\n")}

"all" will grab all VMs

They are stored in #{STORE}
USAGE
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

  def self.download_and_extract(name, urls)
    $l.info "Downloading and extracting #{name.inspect}"
    handler = strategy_for(name, urls)
    $l.info "Using handler #{handler.inspect} for #{name.inspect}"
    raise "can't find strategy to handle: #{name.inspect} (#{urls.inspect})" unless handler
    handler.new(name, urls).download_and_extract
  end

  def self.strategy_for(name, urls)
    strategies.find { |s| s.handle?(name, urls) }
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

    def download_and_extract
      $l.info "Downloading starting"
      download
      $l.info "Downloading finished"
      $l.info "Extraction started"
      extract
      $l.info "Extraction finished"
    end

    def download
      raise NotImplementedError, "#{self.class} needs to override #download"
    end

    def extract
      raise NotImplementedError, "#{self.class} needs to override #extract"
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

  # class ZipStrategy < StrategyBase
  #   def self.handle?(name, urls)
  #     urls.all? {|x| x[/zip\z/i] }
  #   end
  # end

  class OVAStrategy < StrategyBase
    def self.handle?(name, urls)
      urls.all? {|x| x[/ova\z/i] }
    end

    def download
      $l.info "(OVA) downloading started for #{name.inspect}"
      urls.each do |uri|
        destination = cache_path_for(uri.filename)

        unless File.exist?(destination)
          download_file(from: uri, to: destination)
        end
      end
      $l.info "(OVA) downloading finished for #{name.inspect}"
    end

    def extract
      $l.info "(OVA) extraction started for #{name.inspect}"
      Dir[cache_path_for("*.ova")].each do |vm_archive|
        Vbox.destroy(name)
        Vbox.install(vm_archive, as: name)
        Vbox.snapshot(name, "Initial State", description: "Original unbooted pristine state")
      end
      $l.info "(OVA) extraction finished for #{name.inspect}"
    end

    def download_file opts={}
      uri = opts.fetch(:from)
      destination = opts.fetch(:to)

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

  # class RARStrategy < StrategyBase
  #   def self.handle?(name, urls)
  #     urls.first[/sfx\z/i] && urls[1..-1].all? {|x| x[/rar\z/i] }
  #   end
  # end

end

class Vbox
  def self.install vm_archive, opts={}
    vmname = opts.fetch(:as)

    $l.info "[VBOX] Importing #{vm_archive.inspect} as #{vmname.inspect}"
    run("import", vm_archive, "--vsys", "0", "--vmname", vmname)
    $l.info "[VBOX] Finished import of #{vmname.inspect}"
  end

  def self.snapshot vmname, snapshot_name, opts={}
    description = opts[:description]

    $l.info "[VBOX] Snapshotting #{vmname.inspect} as #{snapshot_name.inspect}"

    command_args = ["snapshot", vmname, "take", snapshot_name]
    (command_args << "--description" << description) if description

    run(*command_args)
    $l.info "[VBOX] Finished snapshotting #{vmname.inspect}"
  end

  def self.list_vms
    a = run *%w(list vms)
    a.split("\n").map do |line|
      name, identifier = line.split(" ")
      {name: name.tr('"', ""), identifier: identifier.tr("{}", "")}
    end
  end

  def self.destroy vmname
    $l.info "[VBOX] Destroying #{vmname.inspect}"
    if list_vms.find {|data| data[:name] == vmname }
      run "unregistervm", vmname, "--delete"
    else
      puts "WARN: couldn't find VM named #{vmname.inspect} to destroy"
      true
    end
    $l.info "[VBOX] Destroyed #{vmname.inspect}"
  end

  # Runs the command, printing output as it's given, and returns output as a string
  def self.run *args
    output = ""
    cmd_args = %w(/usr/bin/VBoxManage) | args
    p cmd_args
    IO.popen(cmd_args) do |io|
      print output << (chunk = io.read)
    end
    output
  end
end


# If there are no arguments, or -h, --help, help is passed, print out help and exit
if ARGV.empty? || ARGV.find {|x| %w(-h --help help).include?(x) }
  usage
  exit(1)
end

# Check we can handle the ARGV given; print help and exit if not
# TODO: handle more than one VM being passed, currently we only take the first one
to_grab = ARGV.first.dup
to_grab.downcase! if to_grab
unless to_grab && (to_grab == "all" || VMS.keys.include?(to_grab))
  puts "ERR: unrecognised vm #{to_grab.inspect}\n\n"
  usage
  exit(1)
end

if to_grab == "all"
  VMS.keys.each do |to_grab|
    # Do stuff!
    # Grabber.download_and_extract(to_grab, VMS[to_grab])
  end
else
  # Do stuff!
  Grabber.download_and_extract(to_grab, VMS[to_grab])
end



__END__
# Manually scraped from http://www.modern.ie/en-us/virtualization-tools#downloads
---
IE6_WinXP:
  - "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE6_WinXP.ova.zip"
IE8_XP:
  - "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_XP/IE8.XP.For.MacVirtualBox.ova"
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
IE11_Win7:
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7/IE11.Win7.For.MacVirtualBox.part1.sfx
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7/IE11.Win7.For.MacVirtualBox.part2.rar
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7/IE11.Win7.For.MacVirtualBox.part3.rar
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7/IE11.Win7.For.MacVirtualBox.part4.rar
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7/IE11.Win7.For.MacVirtualBox.part5.rar
IE10_Win8:
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part1.sfx
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part2.rar
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part3.rar
IE11_Win81:
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part1.sfx
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part2.rar
  - https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part3.rar