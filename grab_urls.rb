#!/usr/bin/env ruby
# encoding: UTF-8

require "nokogiri"
require "yaml"
require "json"
require "pp"

original_pos = DATA.pos
grab_data = DATA.read.strip.size == 0
DATA.seek(original_pos)
body = if grab_data
  require "net/https"

  Net::HTTP.get(URI("https://www.modern.ie/en-us/virtualization-tools"))
else
  DATA.read
end

doc = Nokogiri::HTML(body)
data_script = doc.search("script").find { |script| script.text[/vmListJSON/] }
data_json = data_script.to_s[/d\.osList=(\[.+\]);/m, 1]
mac_data = JSON.parse(data_json).find { |d| d["osName"].downcase == "mac" }
virtualbox_data = mac_data["softwareList"].find { |s| s["softwareName"].downcase == "virtualbox" }

print virtualbox_data["browsers"].each_with_object({}) { |browser, url_data|
  name = "IE%s_%s" % [browser["version"], browser["osVersion"]]
  files = browser["files"].map { |f| f["url"] }.find { |f| f[/\.zip\z/] }

  url_data[name] = [files]
}.to_yaml

__END__
