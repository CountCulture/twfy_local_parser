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
      @dummy_response = "some dummy response"
      @scraper.stubs(:_http_get).returns(@dummy_response)
      @parser = @scraper.parser
      @parser.stubs(:process).returns(:foo => "bar", :foo1 => 42)
      @scraper.stubs(:parser).returns(@parser)
      @dummy_member = stub_everything
      Member.stubs(:new).returns(@dummy_member)
    end
       
    should "convert expected_result_attributes to hash" do
      assert_kind_of Hash, @scraper.expected_result_attributes
    end
    
    should "convert expected_result_attributes string to hash keys and values" do
      assert_equal "bar", @scraper.expected_result_attributes[:foo]
    end
    
    should "return empty hash for expected_result_attributes if nil" do
      assert_equal Hash.new, Scraper.new.expected_result_attributes
    end
    
    should "delegate parsing code to parser" do
      @parser.expects(:parsing_code).returns("some code")
      assert_equal "some code", @scraper.parsing_code
    end
    
    should "have results accessor" do
      @scraper.instance_variable_set(:@results, "foo")
      assert_equal "foo", @scraper.results
    end
    
    should_not_allow_mass_assignment_of :results
    
    should "build title from council name and result class" do
      assert_equal "Member scraper for Anytown council", @scraper.title
    end
    
    context "when getting data" do
    
      should "get url page" do
        @scraper.expects(:_http_get).with('http://www.anytown.gov.uk/members/bob').returns("something")
        @scraper.send(:_data)
      end
      
      should "return data as Hpricot Doc" do
        assert_kind_of Hpricot::Doc, @scraper.send(:_data)
      end
      
      should "raise ParsingError when problem processing page with Hpricot" do
        Hpricot.expects(:parse).raises
        assert_raise(Scraper::ParsingError) {@scraper.send(:_data)}
      end
    end
    
    context "when updating" do
      setup do
        @dummy_hpricot_data = stub
        @scraper.stubs(:_data).returns(@dummy_hpricot_data)
      end
      
      # should "get data" do
      #   @scraper.expects(:_data)
      #   @scraper.update
      # end
      
      # should "parse data" do
      #   @parser.expects(:_process).with(@dummy_hpricot_data)
      #   @scraper.update
      # end
      
      # should "update associated item with parsed results" do
      #   dummy_item = mock(:update => {:foo => "bar"})
      #   @scraper.update(dummy_item)
      # end
    end
    
    context "when testing" do
      setup do
        Scraper.any_instance.stubs(:parser).returns(@parser)
        @dummy_hpricot_data = stub
        Scraper.any_instance.stubs(:_data).returns(@dummy_hpricot_data)
      end
      
      should "process page" do
        @parser.expects(:process).with(@dummy_hpricot_data)
        @scraper.test
      end
      
      should "return self" do
        assert_equal @scraper, @scraper.test
      end
      
      should "initialize instance of result_class in results" do
        # assert_equal @scraper, @scraper.test
      end
      
      context "processed result" do
        setup do
          Scraper.any_instance.stubs(:parser).returns(stub(:process => {:full_name => "Fred Wilson", :party => "Independent"}))
          Scraper.any_instance.stubs(:result_model).returns("Member")
        end
        
        should "initialize instance of result_model from result" do
          Member.expects(:new).with({:foo => "bar", :foo1 => 42}) # NB @scraper parser returns this, takes preference over general sttubbing above
          assert @scraper.test
        end
        
        should "stores instance of result model in scraper results attribute as array element" do
          assert_equal 1, @scraper.test.results.size
          assert_equal @dummy_member, @scraper.test.results.first
        end
        
        should "not have errors if no expected results to match against" do
          assert @scraper.test.errors.empty?
        end
               
        should "have errors if result class does not match expected_result_class" do
          scraper = new_scraper(:expected_result_class => "Array")
          assert_equal "was Array, but actual result class was Hash", scraper.test.errors[:expected_result_class]
        end
        
        should "have not have errors if result size does not match expected_result_size but expected_result_size is nil" do
          assert_nil new_scraper.test.errors[:expected_result_size]
        end
        
        should "have not have errors if result size does not match expected_result_size but result is not an array" do
          assert_nil new_scraper(:expected_result_size => 3).test.errors[:expected_result_size]
        end
        
        context "against expected_result_attributes" do
          should "have errors if it is missing required attribute" do
            assert_equal "weren't matched: :foobar expected but was missing or nil", 
                          new_scraper(:expected_result_attributes => ":foobar => true").test.errors[:expected_result_attributes]
          end
          
          should "not have errors if attribute requirements are met" do
            assert_nil new_scraper(:expected_result_attributes => ":full_name => /Wils/, :party => String").test.errors[:expected_result_attributes]
          end
          
          should "have errors if attribute is wrong class" do
            assert_equal "weren't matched: :full_name expected to be Integer but was String", 
                         new_scraper(:expected_result_attributes => ":full_name => Integer").test.errors[:expected_result_attributes]
          end
          
          should "have errors if attribute does not match regexp" do
            assert_equal "weren't matched: :full_name expected to match /baz/ but was 'Fred Wilson'", 
                          new_scraper(:expected_result_attributes => ":full_name => /baz/").test.errors[:expected_result_attributes]
          end
          
          should "have errors if attribute does not match multiple conditions" do
            expected_errors = ["weren't matched: :full_name expected to match /baz/ but was 'Fred Wilson'", "weren't matched: :party expected to be Integer but was String"]
            errors = new_scraper(:expected_result_attributes => ":full_name => /baz/, :party => Integer").test.errors[:expected_result_attributes]
            assert_equal expected_errors.sort, errors.sort # so any problems with ordering is ignored
          end
          
          # decide what to do when attribute is missing -- i.e. should we say that if there's a k-v pair the key must exist, or should we say if it does exist it needs to match
        end
      end
      
      context "processed result array" do
        setup do
          Scraper.any_instance.stubs(:result_model).returns("Member")
          Scraper.any_instance.stubs(:parser).returns(stub(:process => [{:foo => "foobar", :foo1 => 42, :foo2 => [1,2,3]}, {:foo => "bar", :foo1 => nil}]))          
        end

        should "have errors if result size does not match expected_result_size" do
          assert_equal "was 3, but actual result size was 2", new_scraper(:expected_result_size => 3).test.errors[:expected_result_size]
        end

        # should "have errors for each element that fails to match attributes" do
        #   expected_errors = ["weren't matched: :foo expected to match /foo/ but was 'bar' in one element: {:foo=>\"bar\", :foo1=>nil}", 
        #                      "weren't matched: :foo3 expected but was missing or nil in two elements: {:foo=>\"bar\", :foo1=>nil}, {:foo => \"foobar\", :foo1 => 42, :foo2 => [1,2,3]}"]
        #   assert_equal expected_errors, new_scraper(:expected_result_attributes => ":foo => /foo/, :foo3 => true").test.errors[:expected_result_attributes]
        # end
      end
      
    end
  end
  
  private
  def new_scraper(options={})
    Scraper.new(options)
  end
end
