require "spec_helper"

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
      webmaster_tools.crawl_stats(url).should  == {:pages=>{:high=>2406354, :avg=>1184143, :low=>115279}, :kilobytes=>{:high=>34594873, :avg=>17127849, :low=>1968400}, :milliseconds=>{:high=>564, :avg=>443, :low=>283}}
    end
  end

  describe "#suggests", :vcr do
    it 'gets suggests' do
      webmaster_tools.suggests(url).should  == {:duplicate_meta_descriptions=>11104800, :long_meta_descriptions=>52, :short_meta_descriptions=>22, :missing_title_tags=>2, :duplicate_title_tags=>942215}
    end
  end

  describe "#crawl_error_counts", :vcr do
    it 'gets crawl_error_counts' do
      webmaster_tools.crawl_error_counts(url).should  == {"Access denied"=>324, "Not found"=>2000, "Other"=>1997, "Server error"=>1039, "Soft 404"=>14}
    end

    it 'gets crawl_error_counts splitted' do
      webmaster_tools.crawl_error_counts(url, true).to_a.last.should  == ["2012-03-12", {"Server error"=>36, "Other"=>1}]
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
        webmaster_tools.crawl_info(url).first[:indexed_web].to_i.should == 12497184
      end

      it 'gets crawl_info' do
        webmaster_tools.crawl_info(url).last[:indexed_web].to_i.should == 17290270
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
