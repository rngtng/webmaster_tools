require "spec_helper"

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
      webmaster_tools.crawl_stats(url).should  == {:pages=>{:high=>5038900, :avg=>3386448, :low=>494344}, :kilobytes=>{:high=>81386858, :avg=>54885196, :low=>7540876}, :milliseconds=>{:high=>614, :avg=>454, :low=>385}}
    end
  end

  describe "#suggest_counts" do
    it 'gets suggest_counts' do
      webmaster_tools.suggest_counts(url).should  == {:duplicate_meta_descriptions=>7890246, :short_meta_descriptions=>1, :missing_title_tags=>3, :duplicate_title_tags=>786694}
    end
  end

  describe "#crawl_error_counts" do
    it 'gets crawl_error_counts' do
      webmaster_tools.crawl_error_counts(url).should  == {:"400"=>11, :access_denied=>1000, :not_followed=>12, :not_found=>2000, :other=>953, :server_error=>1042, :soft_404=>375}
    end

    it 'gets crawl_error_counts splitted' do
      webmaster_tools.crawl_error_counts(url, true).to_a.last.should  == ["2013-01-06", {:not_found=>2, :access_denied=>3, :other=>1}]
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
        webmaster_tools.crawl_info(url).first[:indexed_web].to_i.should == 31556508
      end

      it 'gets crawl_info' do
        webmaster_tools.crawl_info(url).last[:indexed_web].to_i.should == 31850352
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
