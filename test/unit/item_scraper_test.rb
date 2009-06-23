require 'test_helper'

class ItemScraperTest < ActiveSupport::TestCase
  
  context "The ItemScraper class" do
    
    should "be subclass of Scraper class" do
      assert_equal Scraper, ItemScraper.superclass
    end
  end

  context "an ItemScraper instance" do
    setup do
      @scraper = Factory(:item_scraper)
      @scraper.parser.update_attribute(:result_model, "Meeting")
    end

    should "return what it is scraping for" do
      assert_equal "Meetings from http://www.anytown.gov.uk/members", @scraper.scraping_for
    end
    
    context "with related model" do
      setup do
        @scraper.parser.update_attribute(:related_model, "Committee")
      end

      should "return related model" do
        assert_equal "Committee", @scraper.related_model
      end

      should "get related objects from related model" do
        Committee.expects(:find).with(:all, :conditions => {:council_id => @scraper.council_id}).returns("related_objects")

        assert_equal "related_objects", @scraper.related_objects
      end

      should "not search related model for related_objects when already exist" do
        @scraper.instance_variable_set(:@related_objects, "foo")
        Committee.expects(:find).never
        assert_equal "foo", @scraper.related_objects
      end
    end
    
  
    context "when processing" do
      setup do
        @parser = @scraper.parser
        @parser.stubs(:results).returns([{ :uid => 456 }, { :uid => 457 }] ).then.returns(nil) #second time around finds no results
        @scraper.stubs(:_data).returns("something")
      end
      
      context "item_scraper with url" do
      
        should "get data from url" do
          # This behaviour is inherited from parent Scraper class, so this is (poss unnecessary) sanity check
          @scraper.expects(:_data).with("http://www.anytown.gov.uk/members")
          @scraper.process
        end
      
        should "pass self to associated parser" do
          @parser.expects(:process).with(anything, @scraper).returns(stub_everything(:results => []))
          @scraper.process
        end
        
        should "not update last_scraped attribute if not saving results" do
          assert_nil @scraper.process.last_scraped
        end

        should "update last_scraped attribute if saving results" do
          @scraper.process(:save_results => true)
          assert_in_delta(Time.now, @scraper.reload.last_scraped, 2)
        end
        
        should "not update last_scraped if problem parsing" do
          @parser.stubs(:errors => stub(:empty? => false))
          @scraper.process(:save_results => true)
          assert_nil @scraper.reload.last_scraped
        end

        should "not mark scraper as problematic" do
          @scraper.process
          assert !@scraper.reload.problematic?
        end
      end

      context "and problem getting data" do
        
        setup do
          @scraper.expects(:_data).raises(Scraper::RequestError, "Problem getting data from http://problem.url.com: OpenURI::HTTPError: 404 Not Found")
        end
        
        should "not raise exception" do
          assert_nothing_raised(Exception) { @scraper.process }
        end
        
        should "store error in scraper" do
          @scraper.process
          assert_equal "Problem getting data from http://problem.url.com: OpenURI::HTTPError: 404 Not Found", @scraper.errors[:base]
        end
        
        should "return self" do
          assert_equal @scraper, @scraper.process
        end

        should "not update last_scraped attribute when saving results" do
          assert_nil @scraper.process(:save_results => true).last_scraped
        end

        should "mark scraper as problematic" do
          @scraper.process
          assert @scraper.reload.problematic?
        end
      end

      context "item_scraper with related_model" do
        setup do
          @scraper.parser.update_attribute(:related_model, "Committee")
          
          @committee_1 = Factory(:committee, :council => @scraper.council)
          @committee_2 = Factory(:committee, :council => @scraper.council, :title => "Another Committee", :url => "http://www.anytown.gov.uk/committee/78", :uid => 78)
          dummy_related_objects = [@committee_1, @committee_2]
          @scraper.stubs(:related_objects).returns(dummy_related_objects)
          @scraper.stubs(:_data).returns("something")
        end
        
        context "and url" do

          should "get data from scraper url" do
            @scraper.expects(:_data).with("http://www.anytown.gov.uk/members").twice #once for each related object
            @scraper.process
          end
        end
        
        context "and url with related object in it" do
          setup do
            @scraper.update_attribute(:url, 'http://www.anytown.gov.uk/meetings?ctte_id=#{uid}')
          end

          should "get data from url interpolated with related object" do
            @scraper.expects(:_data).with("http://www.anytown.gov.uk/meetings?ctte_id=77")
            @scraper.expects(:_data).with("http://www.anytown.gov.uk/meetings?ctte_id=78")
            @scraper.process
          end
          
          should "pass self to associated parser" do
            @parser.expects(:process).twice.with(anything, @scraper).returns(stub_everything(:results => []))
            @scraper.process
          end
          
          should "not update last_scraped attribute if not saving results" do
            assert_nil @scraper.process.last_scraped
          end

          should "update last_scraped attribute if saving results" do
            @scraper.process(:save_results => true)
            assert_in_delta(Time.now, @scraper.reload.last_scraped, 2)
          end

          should "not update last_scraped if problem parsing" do
            @parser.stubs(:errors => stub(:empty? => false))
            @scraper.process(:save_results => true)
            assert_nil @scraper.reload.last_scraped
          end
        end
        
        context "and no url" do
          setup do
            @scraper.update_attribute(:url, nil)
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
          
          should "not update last_scraped attribute if not saving results" do
            assert_nil @scraper.process.last_scraped
          end

          should "update last_scraped attribute if saving results" do
            @scraper.process(:save_results => true)
            assert_in_delta(Time.now, @scraper.reload.last_scraped, 2)
          end

          should "not mark scraper as problematic" do
            @scraper.process
            assert !@scraper.reload.problematic?
          end
          
          context "and problem parsing" do
            setup do
              @parser.stubs(:errors => stub(:empty? => false))
              @scraper.process(:save_results => true)
            end
            
            should "not update last_scraped if problem parsing" do
              assert_nil @scraper.reload.last_scraped
            end

            should "mark scraper as problematic" do
              @scraper.process
              assert @scraper.reload.problematic?
            end
          end
          
        end
        
        context "and problem getting data" do

          setup do
            @scraper.expects(:_data).raises(Scraper::RequestError, "Problem getting data from http://problem.url.com: OpenURI::HTTPError: 404 Not Found")
          end

          should "not raise exception" do
            assert_nothing_raised(Exception) { @scraper.process }
          end

          should "store error in scraper" do
            @scraper.process
            assert_equal "Problem getting data from http://problem.url.com: OpenURI::HTTPError: 404 Not Found", @scraper.errors[:base]
          end

          should "return self" do
            assert_equal @scraper, @scraper.process
          end

          should "mark scraper as problematic" do
            @scraper.process
            assert @scraper.reload.problematic?
          end
        end
      end
            
    end
  end
end
