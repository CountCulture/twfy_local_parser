require 'test_helper'


class ScraperTest < ActiveSupport::TestCase
  
  should_belong_to :parser
  should_belong_to :council
  should_validate_presence_of :council_id
  # should_validate_presence_of :parser_id
  should_accept_nested_attributes_for :parser
  # should_allow_values_for :result_model, "Member", "Committee"
  # should_not_allow_values_for :result_model, "foo", "User"
  
  
  context "The Scraper class" do
    
    should "define ScraperError as child of StandardError" do
      assert_equal StandardError, Scraper::ScraperError.superclass
    end
    
    should "define RequestError as child of ScraperError" do
      assert_equal Scraper::ScraperError, Scraper::RequestError.superclass
    end
    
    should "define ParsingError as child of ScraperError" do
      assert_equal Scraper::ScraperError, Scraper::ParsingError.superclass
    end
  end
  
  context "A Scraper instance" do
    setup do
      @scraper = Factory.create(:scraper)
      @council = @scraper.council
      @parser = @scraper.parser
    end
    
    should "not save unless there is an associated parser" do
      s = Scraper.new(:council => @council)
      assert !s.save
      assert_equal "can't be blank", s.errors[:parser]
    end
    
    should "save if there is an associated parser set via parser_id" do
      # just checking...
      s = Scraper.new(:council => @council, :parser_id => @parser.id)
      assert s.save
    end
    
    # should "convert expected_result_attributes to hash" do
    #    assert_kind_of Hash, @scraper.expected_result_attributes
    #  end
    #  
    #  should "convert expected_result_attributes string to hash keys and values" do
    #    assert_equal "bar", @scraper.expected_result_attributes[:foo]
    #  end
    #  
    #  should "return empty hash for expected_result_attributes if nil" do
    #    assert_equal Hash.new, Scraper.new.expected_result_attributes
    #  end
     
    should "delegate result_model to parser" do
      @parser.expects(:result_model).returns("result_model")
      assert_equal "result_model", @scraper.result_model
    end
    
    should "delegate related_model to parser" do
      @parser.expects(:related_model).returns("related_model")
      assert_equal "related_model", @scraper.related_model
    end
    
    should "delegate portal_system to council" do
      @council.expects(:portal_system).returns("portal_system")
      assert_equal "portal_system", @scraper.portal_system
    end
    
    should "delegate base_url to council" do
      @council.expects(:base_url).returns("http://some.council.com/democracy")
      assert_equal "http://some.council.com/democracy", @scraper.base_url
    end
    
    should "have results accessor" do
      @scraper.instance_variable_set(:@results, "foo")
      assert_equal "foo", @scraper.results
    end
    
    should "return empty array as results if not set" do
      assert_equal [], @scraper.results
    end
    
    should "set empty array as results if not set" do
      @scraper.results
      assert_equal [], @scraper.instance_variable_get(:@results)
    end
    
    should_not_allow_mass_assignment_of :results

    should "have parsing_results accessor" do
      @scraper.instance_variable_set(:@parsing_results, "foo")
      assert_equal "foo", @scraper.parsing_results
    end
    
    should "have related_objects accessor" do
      @scraper.instance_variable_set(:@related_objects, "foo")
      assert_equal "foo", @scraper.related_objects
    end
    
    should "build title from council name result class and scraper type when ItemScraper" do
      assert_equal "Member Items scraper for Anytown council", @scraper.title
    end
    
    should "build title from council name result class and scraper type when InfoScraper" do
      assert_equal "Member Info scraper for Anothertown council", Factory.build(:info_scraper).title
    end
    
    should "return errors in parser as parsing errors" do
      @parser.errors.add_to_base("some error")
      assert_equal "some error", @scraper.parsing_errors[:base]
    end
    
    context "that belongs to council with portal system" do
      setup do
        @portal_system = Factory(:portal_system, :name => "Big Portal System")
        @portal_system.parsers << @parser = Factory(:another_parser)
        @council.portal_system = @portal_system
      end

      should "return council's portal system" do
        assert_equal @portal_system, @scraper.portal_system
      end
      
      should "return portal system's parsers as possible parsers" do
        assert_equal [@parser], @scraper.possible_parsers
      end
    end
    
    context "when getting data" do
    
      should "get given url" do
        @scraper.expects(:_http_get).with('http://another.url').returns("something")
        @scraper.send(:_data, 'http://another.url')
      end
      
      should "return data as Hpricot Doc" do
        @scraper.stubs(:_http_get).returns("something")
        assert_kind_of Hpricot::Doc, @scraper.send(:_data)
      end
      
      should "raise ParsingError when problem processing page with Hpricot" do
        Hpricot.expects(:parse).raises
        assert_raise(Scraper::ParsingError) {@scraper.send(:_data)}
      end
    end
        
    context "when processing" do
      setup do
        @parser = @scraper.parser
        @parser.stubs(:results).returns([{ :full_name => "Fred Flintstone", :url => "http://www.anytown.gov.uk/members/fred" }] )
        @scraper.stubs(:_data).returns("something")
      end
      
      should "get data from url" do
        @scraper.expects(:_data).with("http://www.anytown.gov.uk/members/bob")
        @scraper.process
      end
      
      should "pass data to associated parser" do
        @parser.expects(:process).with("something", anything).returns(stub_everything)
        @scraper.process
      end

      should "pass self to associated parser" do
        @parser.expects(:process).with(anything, @scraper).returns(stub_everything)
        @scraper.process
      end

      should "return self" do
        assert_equal @scraper, @scraper.process
      end
      
      should "build new or update existing instance of result_class with parser results and scraper council" do
        dummy_new_member = Member.new
        Member.expects(:build_or_update).with(:full_name => "Fred Flintstone", :council_id => @council.id, :url => "http://www.anytown.gov.uk/members/fred").returns(dummy_new_member)
        dummy_new_member.expects(:save).never
        @scraper.process
      end
      
      should "validate instances of result_class" do
        Member.any_instance.expects(:valid?)
        @scraper.process
      end
      
      should "store instances of result class in results" do
        dummy_member = Member.new
        Member.stubs(:build_or_update).returns(dummy_member)
        assert_equal [dummy_member], @scraper.process.results
      end
      
      context "and problem parsing" do

        should "not build or update instance of result_class if no results" do
          @parser.stubs(:results) # => returns nil
          Member.expects(:build_or_update).never
          @scraper.process
        end
      end
      
      context "and saving results" do

        should "return self" do
          assert_equal @scraper, @scraper.process(:save_results => true)
        end

        should "create new or update and save existing instance of result_class with parser results and scraper council" do
          dummy_new_member = Member.new
          Member.expects(:build_or_update).with(:full_name => "Fred Flintstone", :council_id => @council.id, :url => "http://www.anytown.gov.uk/members/fred").returns(dummy_new_member)
          @scraper.process(:save_results => true)
        end

        should "save record using save_without_losing_dirty" do
          dummy_new_member = Member.new
          Member.stubs(:build_or_update).returns(dummy_new_member)
          dummy_new_member.expects(:save_without_losing_dirty)
          
          @scraper.process(:save_results => true)
        end

        should "store instances of result class in results" do
          dummy_member = Member.new
          Member.stubs(:build_or_update).returns(dummy_member)
          assert_equal [dummy_member], @scraper.process(:save_results => true).results
        end

      end

    end
    
  end
  
  private
  def new_scraper(options={})
    Scraper.new(options)
  end
end
