require "spec_helper"
# require "debugger"

describe WebmasterTools, :vcr do
  let(:webmaster_tools) { WebmasterTools.new("sitemap-stats@testscloud.com", "12test34") }
  let(:url) { "http://testscloud.com/" }

  describe "#login" do
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

  describe "#crawl_stats" do
    it 'gets crawl_stats' do
      webmaster_tools.crawl_stats(url).should  == {:pages=>{:high=>3749227, :avg=>2011501, :low=>526983}, :kilobytes=>{:high=>56952037, :avg=>29845029, :low=>9783669}, :milliseconds=>{:high=>655, :avg=>424, :low=>254}}
    end
  end

  describe "#suggest_counts" do
    it 'gets suggest_counts' do
      webmaster_tools.suggest_counts(url).should  == {:duplicate_meta_descriptions=>8167515, :short_meta_descriptions=>3, :missing_title_tags=>3, :duplicate_title_tags=>981649}
    end
  end

  describe "#crawl_error_counts" do
    it 'gets crawl_error_counts' do
      webmaster_tools.crawl_error_counts(url).should  == {:access_denied=>311, :not_found=>2000, :other=>592, :server_error=>1011, :soft_404=>1}
    end

    it 'gets crawl_error_counts splitted' do
      webmaster_tools.crawl_error_counts(url, true).to_a.last.should  == ["2012-05-31", {:not_found=>3}]
    end
  end

  describe "#security_token" do

    it "gets the token" do
      expect do
        webmaster_tools.send(:security_token, :info, url)
      end.to_not raise_error
    end
  end

  ##########################

  context "amazon url" do
    let(:url) { "http://testscloud-sitemaps.cloudservice-sitemap.hoostings.com/" }

    describe "#dashboard" do
      it 'gets dashboard' do
        expect do
          webmaster_tools.dashboard(url)
        end.to_not raise_error
      end
    end

    describe "#crawl_info" do
      it 'gets crawl_info' do
        webmaster_tools.crawl_info(url).first[:indexed_web].to_i.should == 17182421
      end

      it 'gets crawl_info' do
        webmaster_tools.crawl_info(url).last[:indexed_web].to_i.should == 21833811
      end
    end

    describe "#remove_url" do
      it 'removes url' do
        expect do
          webmaster_tools.remove_url(url + "test2.html")
        end.to_not raise_error
      end
      
      it 'refuses bad removal_type and throws error' do
        expect do
          webmaster_tools.remove_url(url + "test2.html", 'FAKE_TYPE')
        end.to raise_error
      end

      it 'refuses url and throws error' do
        expect do
          webmaster_tools.remove_url("http://wrongurl.com/wrong.html")
        end.to raise_error
      end
    end
  end

end
