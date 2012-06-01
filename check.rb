#!/usr/bin/env ruby
require 'mechanize'
require 'ruby-debug'

Debugger.start

$:.unshift(File.expand_path("../lib", __FILE__))
require "webmaster_tools"
wt = WebmasterTools.new("sitemap-stats@testscloud.com", "12test34")

url = "http://testscloud.com"
#url = "http://testscloud-sitemaps.cloudservice-sitemap.hoostings.com/"
pp errors = wt.crawl_error_counts(url, true)
debugger

puts

__END__
