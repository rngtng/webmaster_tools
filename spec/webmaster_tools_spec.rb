require "spec_helper"

describe WebmasterTools do
  let(:webmaster_tools) { WebmasterTools.new("tobi@testscloud.com", "12test34") }
  let(:url) { "http://testscloud-sitemaps.s3-website-us-east-1.amazonaws.com/" }

  describe "#login", :vcr do
    it 'passes with correct username + password' do
      expect do
        webmaster_tools
      end.to_not raise_error
    end

    it 'fails on wrong username + password' do
      expect do
        WebmasterTools.new("fake", "wrong")
      end
    end
  end

  describe "#dashboard", :vcr do
    it 'gets dashboard' do
      webmaster_tools.dashboard(url).first[:indexed_web] == 11773974
    end

    it 'gets dashboard' do
      webmaster_tools.dashboard(url).last[:indexed_web] ==  17114388
    end
  end

  describe "#security_token", :vcr do
    it 'gets security_token' do
      webmaster_tools.security_token(url).should  == "KgTEUnou385rO2xWpekOpXZ0rds:1331245126703"
    end
  end

  describe "#crawl_info", :vcr do
    it 'gets crawl_info' do
      webmaster_tools.crawl_info(url).first[:indexed_web] == 11773974
    end

    it 'gets crawl_info' do
      webmaster_tools.crawl_info(url).last[:indexed_web] == 17114388
    end
  end

  describe "#crawl_stats", :vcr do
    it 'gets crawl_stats' do
      webmaster_tools.crawl_stats(url).should  == {
        :kilobytes    => {:high => 653227, :avg => 216316, :low => 10711},
        :milliseconds => {:high => 601,    :avg => 409,    :low => 300},
        :pages        => {:high => 1078,   :avg => 265,    :low => 13}
      }
    end
  end

  describe "#crawl_error_counts", :vcr do
    let(:url) { "http://testscloud.com/" }

    it 'gets crawl_error_counts' do
      webmaster_tools.crawl_error_counts(url).should  == {
        :http                       => 499,
        :in_sitemaps                => 100000,
        :not_found                  => 100000,
        :"restricted_by_robots.txt" => 100000,
        :soft_404s                  => 13,
        :unreachable                => 8189
      }
    end
  end
end
