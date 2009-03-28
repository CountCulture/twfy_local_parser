require 'test_helper'

class Foo;end #setup dummy assoc class

class ScraperTest < ActiveSupport::TestCase
  
  should_validate_presence_of :url
  # should_validate_uniqueness_of :title
  should_belong_to :parser
  should_belong_to :council
  
  context "The Scraper class" do
    setup do
      
    end
    
    #should "get url when updating" do
      #Scraper.expects(:_http_get).with
    #end
  
  end
  
  context "A Scraper instance" do
    setup do
      Scraper.stubs(:associated_model).returns(Foo)    
      @scraper = Scraper.create(:url => "some.url")
      @parser = stub(:process => { :foo => "bar" })
      @dummy_response = "some dummy response"
      @scraper.stubs(:_http_get).returns(@dummy_response)
      @scraper.stubs(:_parser).returns(@parser)
    end
    
    should "" do
    
    end
    
    should "get url when updating" do
      @scraper.expects(:_http_get).with('some.url')
      @scraper.update
    end
    
    should "parse response when updating" do
      @parser.expects(:process).with(@dummy_response)
      @scraper.update
    end
    
    should "update associated item with parsed results when updating" do
      dummy_item = mock(:update => {:foo => "bar"})
      @scraper.update(dummy_item)
    end
  end
 
end
