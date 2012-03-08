# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'mechanize'

# WebmasterTools
# required parameters:
#
#   :username  - google username or email
#   :password  - password in plaintext
class WebmasterTools
  LOGIN     = "https://accounts.google.com/ServiceLogin?service=sitemaps"
  AUTH      = "https://accounts.google.com/ServiceLoginAuth"
  REMOVAL   = "https://www.google.com/webmasters/tools/removals-request?hl=en&siteUrl=%s&urlt=%s"
  INFO      = "https://www.google.com/webmasters/tools/sitemaps-dl?hl=en&siteUrl=%s&security_token=%s"
  DASHBOARD = "https://www.google.com/webmasters/tools/dashboard?hl=en&siteUrl=%s"
  ERRORS    = "https://www.google.com/webmasters/tools/crawl-errors?hl=en&siteUrl=%s"
  STATS     = "https://www.google.com/webmasters/tools/crawl-stats?hl=en&siteUrl=%s"
  TOKEN     = "https://www.google.com/webmasters/tools/gwt/SITEMAPS_READ"
  GWT       = "https://www.google.com/webmasters/tools/gwt/"
  GWT_PERM  = "E3DA43109D05B1A5067480CE25494CC2"

  PAYLOAD   = "7|0|11|%s|3EA173CEE6992CFDEAB5C18469B06594|com.google.crawl.wmconsole.fe.feature.gwt.sitemaps.shared.SitemapsService|getDataForMainPage|com.google.crawl.wmconsole.fe.feature.gwt.common.shared.FeatureContext/2156265033|Z|/webmasters/tools|com.google.crawl.wmconsole.fe.feature.gwt.config.FeatureKey/497977451|en|%s|com.google.crawl.wmconsole.fe.base.PermissionLevel/2330262508|1|2|3|4|3|5|6|6|5|7|8|5|9|10|11|5|1|0|"

  def initialize(username, password)
    login(username, password)
  end

  def login(username, password)
    page = agent.get(LOGIN)
    page = agent.submit(page.form.tap do |form|
      form.Email  = username
      form.Passwd = password
    end)
    raise "Wrong username + password combination" if page.content.include?(AUTH)
  end

  def dashboard(url)
    url   = CGI::escape norm_url(url)
    page  = agent.get(DASHBOARD % url)
    page.search("#sitemap tbody .rightmost").map do |node|
      { :indexed_web => node.text.gsub(/\D/, '').to_i }
    end
  end

  def security_token(url)
    # looks like `crawl_error_counts(url)` contains the security_token as well (if data available)...
    dashboard(url) # to trigger referer
    url  = norm_url(url)
    page = agent.post(TOKEN, PAYLOAD % [GWT, url],  {
      "X-GWT-Module-Base" => GWT,
      "X-GWT-Permutation" => GWT_PERM,
      "Content-Type" => "text/x-gwt-rpc; charset=utf-8",
    })
    page.content.scan(/security_token=([^"]+)/).flatten.first
  end

  def crawl_info(url)
    token = security_token(url)
    url   = CGI::escape norm_url(url)
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
    url   = CGI::escape norm_url(url)
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
    url  = CGI::escape norm_url(url)
    page = agent.get(ERRORS % url)

    page.search(".categories a").inject({}) do |hash, n|
      key, value = n.text.split("\n")
      hash[key.downcase.gsub(' ', '_').to_sym] = value.gsub(/\D/, '').to_i
      hash
    end
  end

  def remove_url(url, file)
    url  = CGI::escape norm_url(url)
    page = agent.get(REMOVAL % [url, url + file])
    page = agent.submit page.form
  end

  private
  def agent
    @agent ||= Mechanize.new
  end

  def norm_url(url)
    schema, host = url.scan(/^(https?:\/\/)?(.+?)\/?$/).flatten
    "#{schema || 'http://'}#{host}/"
  end
end
