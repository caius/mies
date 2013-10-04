#!/usr/bin/env ruby
# encoding: UTF-8

require "nokogiri"
require "yaml"

original_pos = DATA.pos
grab_data = DATA.read.strip.size == 0
DATA.seek(original_pos)
if grab_data
  require "capybara"
  require "capybara-webkit"

  Capybara.configure do |c|
    c.default_driver = :webkit
    c.current_driver = :webkit
    c.javascript_driver = :webkit
  end

  include Capybara::DSL

  visit "http://www.modern.ie/en-us/virtualization-tools"

  find("a.expandable-title", text: "Get free VMs").click

  %w{
    $("a.expandable-title[href=\"#downloads\"]").click()
    $("#os-select").val("mac").change()
    $("#platform-select").val("virtbox").change()
  }.each do |js|
    page.execute_script(js)
  end

  File.open(__FILE__, "a+") do |f|
    f.seek(DATA.pos)
    f.puts page.body
  end
end

doc = Nokogiri::HTML(DATA.read)
os_lists = doc.search("#platform-links li")

data = os_lists.inject(Hash.new) do |d, li|
  next(d) unless li.search("div.platform-partial-cell").first

  name = li.search("p.cta").first.text
  urls = li.search(".platform-link-partial").map {|x| x[:href] }

  name.sub!("RP", "Preview")
  name.sub!(" Preview", "preview")
  name.sub!(/Win7.+/, "Win7")
  name.sub!(/ [-–] /, "_")

  d[name] = urls
  d
end

print data.to_yaml

__END__
