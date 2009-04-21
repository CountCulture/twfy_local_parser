require 'test_helper'


class InfoScraperTest < ActiveSupport::TestCase
  
  context "The InfoScraper class" do
    setup do
      @scraper = InfoScraper.new()
    end
    
    should "not validate presence of :url" do
      @scraper.valid? # trigger validation
      assert_nil @scraper.errors[:url]
    end
    
    should "be subclass of Scraper class" do
      assert_equal Scraper, InfoScraper.superclass
    end
  end
  
  context "an InfoScraper instance" do
    setup do
      @scraper = Factory.create(:info_scraper)
    end
    
    should "ignore url if set" do
      assert_nil InfoScraper.new(:url => "http://foo.com").url
    end
    
    should "use url from info_objects" do
      @scraper.instance_variable_set(:@info_object, stub(:url => "http://bar.com"))
      assert_equal "http://bar.com", @scraper.url
    end
    
    should "return nil for url if info_object doesn't exist" do
      assert_nil @scraper.url
    end

    context "when updating from url" do
      setup do
        @dummy_info_object = Member.new
        @scraper.stubs(:process)
        @scraper.stubs(:parsing_results).returns([{ :full_name => "Fred Flintstone", :url => "http://www.anytown.gov.uk/members/fred" }] )
      end
      
      should "process url" do
        @scraper.expects(:process)
        @scraper.update_from_url(@dummy_info_object)
      end

      should "set info_object even if given" do
        @scraper.update_from_url(@dummy_info_object)
        assert_equal @dummy_info_object, @scraper.info_object
      end
      
      # should "raise exception if info_object not given" do
      #   assert_raise(ArgumentError) { @scraper.update_from_url }
      # end

      should "update existing instance of result_class" do
        @dummy_info_object.expects(:update_attributes).with({ :full_name => "Fred Flintstone", :url => "http://www.anytown.gov.uk/members/fred" })
        @scraper.update_from_url(@dummy_info_object)
      end
      
      should "not build new or update existing instance of result_class" do
        Member.expects(:create_or_update_and_save).never
        @scraper.update_from_url(@dummy_info_object)
      end
      
      
      should "store updated existing instance in results" do
        assert_equal [@dummy_info_object], @scraper.update_from_url(@dummy_info_object).results
      end

    end
    
    context "when testing" do
      setup do
        @scraper.stubs(:process)
        @dummy_info_object = Member.new
        @scraper.stubs(:parsing_results).returns([{ :full_name => "Fred Flintstone", :url => "http://www.anytown.gov.uk/members/fred" }] )
      end
      
      should "process url" do
        @scraper.expects(:process)
        @scraper.test(@dummy_info_object)
      end

      should "set info_object" do
        @scraper.test(@dummy_info_object)
        assert_equal @dummy_info_object, @scraper.info_object
      end

      should "raise exception if info_object not given" do
        assert_raise(ArgumentError) { @scraper.test }
      end

      should "return self" do
        assert_equal @scraper, @scraper.test(@dummy_info_object)
      end
      
      should "update existing instance of result_class" do
        @scraper.test(@dummy_info_object)
        assert_equal "Fred Flintstone", @dummy_info_object.full_name
      end
      
      should "not build new or update existing instance of result_class" do
        Member.expects(:build_or_update).never
        @scraper.test(@dummy_info_object)
      end
      
      should "validate existing instance of result_class" do
        @scraper.test(@dummy_info_object)
        assert @dummy_info_object.errors[:uid]
      end
      
      should "store updated existing instance in results" do
        assert_equal [@dummy_info_object], @scraper.test(@dummy_info_object).results
      end

    end
  end
  
end
