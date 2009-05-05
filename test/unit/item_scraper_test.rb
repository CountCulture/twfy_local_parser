require 'test_helper'

class ItemScraperTest < ActiveSupport::TestCase
  
  context "The ItemScraper class" do
    
    should_validate_presence_of :url
    should_have_db_column :related_model
    should "be subclass of Scraper class" do
      assert_equal Scraper, ItemScraper.superclass
    end
  end

  context "an ItemScraper instance" do
    setup do
      @scraper = Factory(:item_scraper, :result_model => "Meeting")
    end

    should "return what it is scraping for" do
      assert_equal "Meetings from http://www.anytown.gov.uk/members", @scraper.scraping_for
    end
    
    context "with related model" do
      setup do
        @related_model_scraper = ItemScraper.new(:related_model => "Committee", :council_id => 44)
      end

      should "return related model" do
        assert_equal "Committee", @related_model_scraper.related_model
      end

      should "get related objects from related model" do
        Committee.expects(:find).with(:all, :conditions => {:council_id => @related_model_scraper.council_id}).returns("related_objects")

        assert_equal "related_objects", @related_model_scraper.related_objects
      end

      should "not search related model for related_objects when already exist" do
        @related_model_scraper.instance_variable_set(:@related_objects, "foo")
        Committee.expects(:find).never
        assert_equal "foo", @related_model_scraper.related_objects
      end
    end
    
  
    context "when processing" do
      setup do
        @parser = @scraper.parser
        @parser.stubs(:results).returns([{ :uid => 456 }, { :uid => 457 }] ).then.returns(nil) #second time around finds no results
        @scraper.stubs(:_data).returns("something")
      end
      
      context "with item_scraper with url" do
      
        should "get data from url" do
          # This behaviour is inherited from parent Scraper class, so this is (poss unnecessary) sanity check
          @scraper.expects(:_data).with("http://www.anytown.gov.uk/members")
          @scraper.process
        end
      
      end
      context "with item_scraper with related_model" do
        setup do
          @scraper.update_attribute(:related_model, "Committee")
          @committee_1 = Factory(:committee, :council => @scraper.council)
          @committee_2 = Factory(:committee, :council => @scraper.council, :title => "Another Committee", :url => "http://www.anytown.gov.uk/committee/78")
          dummy_related_objects = [@committee_1, @committee_2]
          @scraper.stubs(:related_objects).returns(dummy_related_objects)
          @scraper.stubs(:_data).returns("something")
        end
      
        should "not get data from scraper url" do
          @scraper.expects(:_data).with("http://www.anytown.gov.uk/members").never
          @scraper.process
        end
      
        should "get data from each related_object's url" do
          @scraper.expects(:_data).with("http://www.anytown.gov.uk/committee/77")
          @scraper.expects(:_data).with("http://www.anytown.gov.uk/committee/78")
          @scraper.process
        end
      
        should "update result model with each result and related object details" do
          @scraper.expects(:update_with_results).with([{ :committee_id => @committee_1.id, :uid => 456 }, { :committee_id => @committee_1.id, :uid => 457 }], anything)
          @scraper.process
        end
        
        should "update result model passing on any options" do
          @scraper.expects(:update_with_results).with(anything, {:foo => "bar"})
          @scraper.process({:foo => "bar"})
        end
        
      end
  
    end
  end
end
