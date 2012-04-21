require "spec_helper"
# require "debugger"

describe WebmasterTools do
  let(:webmaster_tools) { WebmasterTools.new("sitemap-stats@testscloud.com", "12test34") }
  let(:url) { "http://testscloud.com/" }

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

  describe "#crawl_stats", :vcr do
    it 'gets crawl_stats' do
      webmaster_tools.crawl_stats(url).should  == {:pages=>{:high=>3273615, :avg=>1902882, :low=>884591}, :kilobytes=>{:high=>48439792, :avg=>27330591, :low=>12862452}, :milliseconds=>{:high=>564, :avg=>437, :low=>283}}
    end
  end

  describe "#suggest_counts", :vcr do
    it 'gets suggest_counts' do
      webmaster_tools.suggest_counts(url).should  == {:duplicate_meta_descriptions=>11378053, :short_meta_descriptions=>30, :missing_title_tags=>8, :duplicate_title_tags=>983513}
    end
  end

  describe "#crawl_error_counts", :vcr do
    it 'gets crawl_error_counts' do
      webmaster_tools.crawl_error_counts(url).should  == {:access_denied=>369, :not_found=>1999, :other=>1119, :server_error=>1018, :soft_404=>13}
    end

    it 'gets crawl_error_counts splitted' do
      webmaster_tools.crawl_error_counts(url, true).to_a.last.should  == ["2012-04-20", {:server_error=>12}]
    end
  end

  ##########################

  context "amazon url" do
    let(:url) { "http://testscloud-sitemaps.cloudservice-sitemap.hoostings.com/" }

    describe "#dashboard", :vcr do
      it 'gets dashboard' do
        expect do
          webmaster_tools.dashboard(url)
        end.to_not raise_error
      end
    end

    describe "#crawl_info", :vcr do
      it 'gets crawl_info' do
        webmaster_tools.crawl_info(url).first[:indexed_web].to_i.should == 15575423
      end

      it 'gets crawl_info' do
        webmaster_tools.crawl_info(url).last[:indexed_web].to_i.should == 19882785
      end
    end

    describe "#remove_url", :vcr do
      it 'removes url' do
        expect do
          webmaster_tools.remove_url(url + "test2.html")
        end.to_not raise_error
      end

      it 'refuses url and throws error' do
        expect do
          webmaster_tools.remove_url("http://wrongurl.com/wrong.html")
        end.to raise_error
      end
    end
  end

end
