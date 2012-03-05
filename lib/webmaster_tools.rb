# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'mechanize'

# WebmasterTools
# Parameters:
#  required:
#   :username  -
#   :password  -
#
#  optional:
#   :url -
#   :security_token -
class WebmasterTools
  LOGIN     = "https://accounts.google.com/ServiceLogin?service=sitemaps"
  REMOVAL   = "https://www.google.com/webmasters/tools/removals-request?hl=en&siteUrl=%s&urlt=%s"
  INFO      = "https://www.google.com/webmasters/tools/sitemaps-dl?hl=en&siteUrl=%s&security_token=%s"
  DASHBOARD = "https://www.google.com/webmasters/tools/dashboard?hl=en&siteUrl=%s"
  ERRORS    = "https://www.google.com/webmasters/tools/crawl-errors?hl=en&siteUrl=%s"
  STATS     = "https://www.google.com/webmasters/tools/crawl-stats?hl=en&siteUrl=%s"

  def initialize(username, password)
    login(username, password)
  end

  def login(username, password)
    page = agent.get(LOGIN)
    page = agent.submit(page.form.tap do |form|
      form.Email  = username
      form.Passwd = password
    end)
  end

  def dashboard(url)
    url   = norm_url(url)
    page  = agent.get(DASHBOARD % url)
    {
      :indexed => page.search("#sitemap tbody .rightmost").text.gsub(/\D/, '').to_i
    }
  end

  def crawl_info(url, token)
    url   = norm_url(url)
    page  = agent.get(INFO % [url, token])

    lines = page.content.split("\n").map do |line|
      line.split(",")
    end
    head  = lines.shift.map { |key| key.downcase.gsub(' ', '_').to_sym }

    $lines = lines.map do |line|
      Hash[head.zip(line)]
    end
  end

  def crawl_stats(url)
    url   = norm_url(url)
    types = %w(pages kilobytes milliseconds).map(&:to_sym)
    head  = %w(high avg low).map(&:to_sym)

    page  = agent.get(STATS % url)

    Hash[types.zip(page.search(".hostload-activity tr td").map do |node|
      node.text.gsub(/\D/, '').to_i
    end.each_slice(3).map do |slice|
      Hash[head.zip(slice)]
    end)]
  end

  def crawl_error_counts(url)
    url  = norm_url(url)
    page = agent.get(ERRORS % url)

    page.search(".categories a").inject({}) do |hash, n|
      key, value = n.text.split("\n")
      hash[key.downcase.gsub(' ', '_').to_sym] = value.gsub(/\D/, '').to_i
      hash
    end
  end

  def remove_url(url, file)
    url  = norm_url(url)
    page = agent.get(REMOVAL % [url, url + file])
    page = agent.submit page.form
  end

  private
  def agent
    @agent ||= Mechanize.new
  end

  def norm_url(url)
    schema, host = url.scan(/^(https?:\/\/)?(.+?)\/?$/).flatten
    CGI::escape "#{schema || 'http://'}#{host}/"
  end
end
