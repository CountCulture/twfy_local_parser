require 'test_helper'


class ItemScraperTest < ActiveSupport::TestCase
  
  
  context "The ItemScraper class" do
    
    should_validate_presence_of :url
    should "be subclass of Scraper class" do
      assert_equal Scraper, ItemScraper.superclass
    end

  end

end
