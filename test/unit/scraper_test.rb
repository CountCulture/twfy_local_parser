require 'test_helper'


class ScraperTest < ActiveSupport::TestCase
  
  should_validate_presence_of :url
  should_belong_to :parser
  should_belong_to :council
  should_validate_presence_of :council_id
  should_validate_presence_of :result_model
  should_accept_nested_attributes_for :parser
  should_allow_values_for :result_model, "Member", "Committee"
  should_not_allow_values_for :result_model, "foo", "User"
  
  
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
      # @scraper.stubs(:_http_get).returns(@dummy_response)
      @parser = @scraper.parser
      # # @parser.stubs(:process).returns(:foo => "bar", :foo1 => 42)
      # # @scraper.stubs(:parser).returns(@parser)
      # @dummy_member = stub_everything
      # Member.stubs(:new).returns(@dummy_member)
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
     
    # should "delegate parsing code to parser" do
    #   @parser.expects(:item_parser).returns("some code")
    #   assert_equal "some code", @scraper.item_parser
    # end
    
    should "have results accessor" do
      @scraper.instance_variable_set(:@results, "foo")
      assert_equal "foo", @scraper.results
    end
    
    should "have parsing_results accessor" do
      @scraper.instance_variable_set(:@parsing_results, "foo")
      assert_equal "foo", @scraper.parsing_results
    end
    
    should_not_allow_mass_assignment_of :results
    
    should "build title from council name and result class" do
      assert_equal "Member scraper for Anytown council", @scraper.title
    end
    
    should "return erros in parser as parsing errors" do
      @parser.errors.add_to_base("some error")
      assert_equal "some error", @scraper.parsing_errors[:base]
    end
    
    context "when getting data" do
    
      should "get url page" do
        @scraper.expects(:_http_get).with('http://www.anytown.gov.uk/members/bob').returns("something")
        @scraper.send(:_data)
      end
      
      should "return data as Hpricot Doc" do
        @scraper.stubs(:_http_get).with('http://www.anytown.gov.uk/members/bob').returns("something")
        assert_kind_of Hpricot::Doc, @scraper.send(:_data)
      end
      
      should "raise ParsingError when problem processing page with Hpricot" do
        Hpricot.expects(:parse).raises
        assert_raise(Scraper::ParsingError) {@scraper.send(:_data)}
      end
    end
    
    context "when processing" do
      setup do
        @parser.stubs(:process).returns(@parser)
        @parser.stubs(:results).returns({:foo => "bar", :foo1 => 42})            
        @dummy_hpricot_object = Hpricot("some dummy response")
        @scraper.stubs(:_data).returns(@dummy_hpricot_object)
      end

      should "get data" do
        @scraper.expects(:_data)
        @scraper.process
      end
      
      should "pass data to associated parser" do
        @parser.expects(:process).with(@dummy_hpricot_object).returns(stub_everything)
        @scraper.process
      end
      
      
      should "make results from parser available through parsing_results accessor" do
        @scraper.process
        assert_equal ({:foo => "bar", :foo1 => 42}), @scraper.parsing_results
      end
      
    end
    
    context "when updating from url" do
      setup do
        @scraper.stubs(:process)
        @scraper.stubs(:parsing_results).returns([{ :full_name => "Fred Flintstone", :url => "http://www.anytown.gov.uk/members/fred" }] )
      end
      
      should "process url" do
        @scraper.expects(:process)
        @scraper.update_from_url
      end
      
      should "return self" do
        assert_equal @scraper, @scraper.update_from_url
      end
      
      should "create new or update and save existing instance of result_class with parser results and scraper council" do
        Member.expects(:create_or_update_and_save).with(:full_name => "Fred Flintstone", :council_id => @council.id, :url => "http://www.anytown.gov.uk/members/fred").returns(Member.new)
        @scraper.update_from_url
      end
      
      should "store instances of result class in results" do
        dummy_member = Member.new
        Member.stubs(:create_or_update_and_save).returns(dummy_member)
        assert_equal [dummy_member], @scraper.update_from_url.results
      end
    end
    
    context "when testing" do
      setup do
        @scraper.stubs(:process)
        @scraper.stubs(:parsing_results).returns([{ :full_name => "Fred Flintstone", :url => "http://www.anytown.gov.uk/members/fred" }] )
      end
      
      should "process url" do
        @scraper.expects(:process)
        @scraper.test
      end
      
      should "return self" do
        assert_equal @scraper, @scraper.test
      end
      
      should "build new or update existing instance of result_class with parser results and scraper council" do
        Member.expects(:build_or_update).with(:full_name => "Fred Flintstone", :council_id => @council.id, :url => "http://www.anytown.gov.uk/members/fred").returns(Member.new)
        @scraper.test
      end
      
      should "validate instances of result_class" do
        Member.any_instance.expects(:valid?)
        @scraper.test
      end
      
      should "store instances of result class in results" do
        dummy_member = Member.new
        Member.stubs(:build_or_update).returns(dummy_member)
        assert_equal [dummy_member], @scraper.test.results
      end
      
    #   context "processed result" do
    #     setup do
    #       Scraper.any_instance.stubs(:parser).returns(stub(:process => {:full_name => "Fred Wilson", :party => "Independent"}))
    #       Scraper.any_instance.stubs(:result_model).returns("Member")
    #     end
    #     
    #     should "initialize instance of result_model from result" do
    #       Member.expects(:new).with({:foo => "bar", :foo1 => 42}) # NB @scraper parser returns this, takes preference over general sttubbing above
    #       assert @scraper.test
    #     end
    #     
    #     should "stores instance of result model in scraper results attribute as array element" do
    #       assert_equal 1, @scraper.test.results.size
    #       assert_equal @dummy_member, @scraper.test.results.first
    #     end
    #     
    #     should "not have errors if no expected results to match against" do
    #       assert @scraper.test.errors.empty?
    #     end
    #            
    #     should "have errors if result class does not match expected_result_class" do
    #       scraper = new_scraper(:expected_result_class => "Array")
    #       assert_equal "was Array, but actual result class was Hash", scraper.test.errors[:expected_result_class]
    #     end
    #     
    #     should "have not have errors if result size does not match expected_result_size but expected_result_size is nil" do
    #       assert_nil new_scraper.test.errors[:expected_result_size]
    #     end
    #     
    #     should "have not have errors if result size does not match expected_result_size but result is not an array" do
    #       assert_nil new_scraper(:expected_result_size => 3).test.errors[:expected_result_size]
    #     end
    #     
    #     context "against expected_result_attributes" do
    #       should "have errors if it is missing required attribute" do
    #         assert_equal "weren't matched: :foobar expected but was missing or nil", 
    #                       new_scraper(:expected_result_attributes => ":foobar => true").test.errors[:expected_result_attributes]
    #       end
    #       
    #       should "not have errors if attribute requirements are met" do
    #         assert_nil new_scraper(:expected_result_attributes => ":full_name => /Wils/, :party => String").test.errors[:expected_result_attributes]
    #       end
    #       
    #       should "have errors if attribute is wrong class" do
    #         assert_equal "weren't matched: :full_name expected to be Integer but was String", 
    #                      new_scraper(:expected_result_attributes => ":full_name => Integer").test.errors[:expected_result_attributes]
    #       end
    #       
    #       should "have errors if attribute does not match regexp" do
    #         assert_equal "weren't matched: :full_name expected to match /baz/ but was 'Fred Wilson'", 
    #                       new_scraper(:expected_result_attributes => ":full_name => /baz/").test.errors[:expected_result_attributes]
    #       end
    #       
    #       should "have errors if attribute does not match multiple conditions" do
    #         expected_errors = ["weren't matched: :full_name expected to match /baz/ but was 'Fred Wilson'", "weren't matched: :party expected to be Integer but was String"]
    #         errors = new_scraper(:expected_result_attributes => ":full_name => /baz/, :party => Integer").test.errors[:expected_result_attributes]
    #         assert_equal expected_errors.sort, errors.sort # so any problems with ordering is ignored
    #       end
    #       
    #       # decide what to do when attribute is missing -- i.e. should we say that if there's a k-v pair the key must exist, or should we say if it does exist it needs to match
    #     end
    #   end
    #   
    #   context "processed result array" do
    #     setup do
    #       Scraper.any_instance.stubs(:result_model).returns("Member")
    #       Scraper.any_instance.stubs(:parser).returns(stub(:process => [{:foo => "foobar", :foo1 => 42, :foo2 => [1,2,3]}, {:foo => "bar", :foo1 => nil}]))          
    #     end
    # 
    #     should "have errors if result size does not match expected_result_size" do
    #       assert_equal "was 3, but actual result size was 2", new_scraper(:expected_result_size => 3).test.errors[:expected_result_size]
    #     end
    # 
    #     # should "have errors for each element that fails to match attributes" do
    #     #   expected_errors = ["weren't matched: :foo expected to match /foo/ but was 'bar' in one element: {:foo=>\"bar\", :foo1=>nil}", 
    #     #                      "weren't matched: :foo3 expected but was missing or nil in two elements: {:foo=>\"bar\", :foo1=>nil}, {:foo => \"foobar\", :foo1 => 42, :foo2 => [1,2,3]}"]
    #     #   assert_equal expected_errors, new_scraper(:expected_result_attributes => ":foo => /foo/, :foo3 => true").test.errors[:expected_result_attributes]
    #     # end
    #   end
    #   
    end
  end
  
  private
  def new_scraper(options={})
    Scraper.new(options)
  end
end
