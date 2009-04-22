require 'test_helper'

class ItemScraperTest < ActiveSupport::TestCase
  
  context "The ItemScraper class" do
    
    should_validate_presence_of :url
    should "be subclass of Scraper class" do
      assert_equal Scraper, ItemScraper.superclass
    end
  end

  context "an ItemScraper instance" do
    setup do
      @scraper = Factory(:item_scraper)
    end

    should "return what it is scraping for" do
      assert_equal "Members from http://www.anytown.gov.uk/members", @scraper.scraping_for
    end
    
  end
  
end
