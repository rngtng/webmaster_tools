# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'mechanize'

# WebmasterTools
# required parameters:
#
#   :username  - google username or email
#   :password  - password in plaintext
class WebmasterTools
  LOGIN       = "https://accounts.google.com/ServiceLogin?service=sitemaps"
  AUTH        = "https://accounts.google.com/ServiceLoginAuth"

  DASHBOARD   = "https://www.google.com/webmasters/tools/dashboard?hl=en&siteUrl=%s"
  STATS       = "https://www.google.com/webmasters/tools/crawl-stats?hl=en&siteUrl=%s"
  SUGGESTS    = "https://www.google.com/webmasters/tools/html-suggestions?hl=en&siteUrl=%s"
  REMOVAL     = "https://www.google.com/webmasters/tools/removals-request?hl=en&siteUrl=%s&urlt=%s"
  REMOVALS     = "https://www.google.com/webmasters/tools/url-removal?hl=en&siteUrl=%s&urlt=%s&rlf=all&grid.r=0&grid.s=%s"

  GWT_URL     = "https://www.google.com/webmasters/tools/gwt/"

  GWT         = {
    # :select => {
    #   :action => "SITE_SELECTOR",
    #   :perm   => "3E83D794404733556D909F0916E6641E",
    #   :data   => '7|0|13|%s|FCC81D20B05EEB177130C930CD8B412E|com.google.crawl.wmconsole.fe.feature.gwt.common.shared.siteselector.SiteSelectorService|getAllSites|com.google.crawl.wmconsole.fe.feature.gwt.base.shared.FeatureContext/101412349|java.lang.String/2004016611|/webmasters/tools|{"currentSiteName":"testscloud-sitemaps.cloudservice-sitemap.hoostings.com","recentSiteUrls":["https://www.google.com/webmasters/tools/sitemap-list?hl=en&siteUrl=http://testscloud.com/","https://www.google.com/webmasters/tools/sitemap-list?hl=en&siteUrl=http://www.testscloud.com/","https://www.google.com/webmasters/tools/sitemap-list?hl=en&siteUrl=http://testscloud-sitemaps.s3.hoostings.com/","https://www.google.com/webmasters/tools/sitemap-list?hl=en&siteUrl=http://m.testscloud.com/","https://www.google.com/webmasters/tools/sitemap-list?hl=en&siteUrl=http://sandbox-testscloud.com/"],"hasMultipleSites":true,"siteFaviconUrl":"//s2.googleusercontent.com/s2/favicons?domain_url=http://testscloud-sitemaps.cloudservice-sitemap.hoostings.com/","recentSiteNames":["testscloud.com","www.testscloud.com","testscloud-sitemaps.s3.hoostings.com","m.testscloud.com","sandbox-testscloud.com"]}|com.google.crawl.wmconsole.fe.feature.gwt.config.FeatureKey/497977451|en|http://testscloud-sitemaps.cloudservice-sitemap.hoostings.com/|com.google.crawl.wmconsole.fe.base.PermissionLevel/2330262508|https://www.google.com/webmasters/tools/sitemap-list?hl=en&siteUrl=http://testscloud-sitemaps.cloudservice-sitemap.hoostings.com/#MAIN_TAB=0&CARD_TAB=-1|1|2|3|4|2|5|6|5|7|8|9|5|10|11|12|5|13|',
    #   :dl     => "https://www.google.com/webmasters/tools/sitemaps-dl?hl=en&siteUrl=%s&security_token=%s",
    # },
    :info => {
      :action => "SITEMAPS_READ",
      :perm   => "3E83D794404733556D909F0916E6641E",
      :data   => "7|0|11|%s|0DD967D4FC5CC1A0702DC7ECFB48549A|com.google.crawl.wmconsole.fe.feature.gwt.sitemaps.shared.SitemapsService|getDataForMainPage|com.google.crawl.wmconsole.fe.feature.gwt.base.shared.FeatureContext/101412349|Z|/webmasters/tools|com.google.crawl.wmconsole.fe.feature.gwt.config.FeatureKey/497977451|en|%s|com.google.crawl.wmconsole.fe.base.PermissionLevel/2330262508|1|2|3|4|3|5|6|6|5|7|0|8|6|9|10|11|5|1|0|",
      :dl     => "https://www.google.com/webmasters/tools/sitemaps-dl?hl=en&siteUrl=%s&security_token=%s",
    },
    :error => {
      :action => "CRAWLERRORS_READ",
      :perm   => "3E83D794404733556D909F0916E6641E",
      :data   => "7|0|10|%s|5ED7DB19A1883A7245AB65FD59F043C3|com.google.crawl.wmconsole.fe.feature.gwt.crawlerrors.shared.CrawlErrorsService|getSiteLevelData|com.google.crawl.wmconsole.fe.feature.gwt.base.shared.FeatureContext/101412349|/webmasters/tools|com.google.crawl.wmconsole.fe.feature.gwt.config.FeatureKey/497977451|en|%s|com.google.crawl.wmconsole.fe.base.PermissionLevel/2330262508|1|2|3|4|1|5|5|6|0|7|1|8|9|10|5|",
      :dl     => "https://www.google.com/webmasters/tools/crawl-errors-new-dl?hl=en&siteUrl=%s&security_token=%s",
    }
  }

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

  ################

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

  def suggest_counts(url)
    url  = CGI::escape norm_url(url)
    page = agent.get(SUGGESTS % url)

    page.search(".g-section tr").inject({}) do |hash, n|
      if (key = n.search("a").first) && (value = n.search(".pages").first)
        hash[to_key(key.text)] = to_value(value.text)
      end
      hash
    end
  end

  # Possible Removal Types are:  ["PAGE", "PAGE_CACHE", "DIRECTORY"]
  def remove_url(url_with_file, removal_type = "PAGE")
    url   = CGI::escape norm_url(url_with_file)
    page  = agent.get(REMOVAL % [url, CGI::escape(url_with_file)])

    page.form.field_with(:name => 'removalmethod').value = removal_type
    page  = agent.submit page.form
    files = page.search(".wmt-external-url").map { |n| File.basename(n.text) }
    raise "could not submit URL" unless files.include?(File.basename(url_with_file))
  end

  def removal_stats(url, max_results = 100)
    url   = CGI::escape norm_url(url)
    page  = agent.get(REMOVALS % [url, CGI::escape(url), max_results])

    removals_array = page.search('.grid tr').collect do |row|
      next if row.at("td[1]").nil?

      url     =    row.search('.wmt-external-url').text.strip
      status  =    row.at("td[2]").text.strip
      type    =    row.at("td[3]").text.strip
      date    =    row.at("td[4]").text.strip

      if status.include?('Removed')
        status = 'Removed'
      elsif status.include?('Denied')
        status = 'Denied'
      elsif status.include?('Pending')
        status = 'Pending'
      end

      {:url => url, :status => status, :type => type, :date => date}
    end.compact
    return removals_array
  end

  ###########################

  def crawl_info(url)
    url   = norm_url(url)
    token = security_token(:info, url)
    page  = agent.get(GWT[:info][:dl] % [CGI::escape(url), token])

    lines = page.content.split("\n").map do |line|
      line.split(",")
    end
    head  = lines.shift.map { |key| key.downcase.gsub(' ', '_').to_sym }

    lines.map do |line|
      Hash[head.zip(line)]
    end
  end

  def crawl_error_counts(url, split = false)
    url = norm_url(url)
    token = security_token(:error, url)
    page  = agent.get(GWT[:error][:dl] % [CGI::escape(url), token])

    lines = page.content.split("\n").map do |line|
      line.split(",")
    end
    head  = lines.shift.map { |key| key.downcase.gsub(' ', '_').to_sym }

    errors = lines.inject({}) do |hash, line|
      url, response_code, _, detected, category = *line
      detected = "20#{$3}-#{'%02d' % $1.to_i}-#{'%02d' % $2.to_i}" if /(\d{1,2})\/(\d{1,2})\/(\d{2})/ =~ detected
      if !category.to_s.empty? && !(category =~ /[\/%]/)
        sub_hash = split ? (hash[detected] ||= {}) : hash
        sub_hash[to_key(category)] ||= 0
        sub_hash[to_key(category)]  += 1
      end
      hash
    end
    Hash[errors.sort { |a,b| a[0] <=> b[0] }]
  end

  private
  def agent
    @agent ||= Mechanize.new
  end

  def norm_url(url)
    schema, host, _ = url.scan(/^(https?:\/\/)?(.+?)(\/.*)?$/).flatten
    "#{schema || 'http://'}#{host}/"
  end

  def security_token(action, url)
    dashboard(url) # to trigger referer
    page = agent.post(GWT_URL + GWT[action][:action], GWT[action][:data] % [GWT_URL, url],  {
      "X-GWT-Module-Base" => GWT_URL,
      "X-GWT-Permutation" => GWT[action][:perm],
      "Content-Type" => "text/x-gwt-rpc; charset=utf-8",
    })
    # debugger
    page.content.scan(/security_token\\x3D([^"]+)/).flatten.first.tap do |token|
      raise "Empty security Token" if token.to_s.empty?
    end
  end

  def to_key(key)
    key.downcase.gsub(' ', '_').to_sym
  end

  def to_value(value)
    value.gsub(/\D/, '').to_i
  end
end

