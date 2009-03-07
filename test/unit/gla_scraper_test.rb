require 'test_helper'
class GlaScraperTest < ActiveSupport::TestCase

  context "A Gla scraper" do
    
    setup do
      @scraper = Gla::Scraper.new(:target_page => "/assembly/lams_facts_cont.jsp")
    end

    should "have a base url" do
      assert_equal "http://www.london.gov.uk", @scraper.base_url
    end
    
    should "have a target url" do
      assert_equal "/assembly/lams_facts_cont.jsp", @scraper.target_page
    end
    
    should "get response to using base_url and target page" do
      
      @scraper.expects(:_http_get).with("http://www.london.gov.uk/assembly/lams_facts_cont.jsp").returns("some response")
      @scraper.response
    end
    
    should "return Hpricot Doc object as response" do
      @scraper.stubs(:_http_get).with("http://www.london.gov.uk/assembly/lams_facts_cont.jsp").returns("some response")
      assert_kind_of Hpricot::Doc, @scraper.response
    end
  end
  
  private
  
end
