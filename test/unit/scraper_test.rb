require 'test_helper'

class Foo;end #setup dummy assoc class

class ScraperTest < ActiveSupport::TestCase
  
  should_validate_presence_of :url
  should_belong_to :parser
  should_belong_to :council
  should_validate_presence_of :council_id
  should_validate_presence_of :result_model
  should_accept_nested_attributes_for :parser
  
  context "The Scraper class" do
    setup do
      
    end
    
    #should "get url when updating" do
      #Scraper.expects(:_http_get).with
    #end
  
  end
  
  context "A Scraper instance" do
    setup do
      @scraper = Factory(:scraper)
      @dummy_response = "some dummy response"
      @scraper.stubs(:_http_get).returns(@dummy_response)
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
      parser = mock(:parsing_code => "some code")
      @scraper.stubs(:parser).returns(parser)
      assert_equal "some code", @scraper.parsing_code
    end
    
    should "have results accessor" do
      @scraper.instance_variable_set(:@results, "foo")
      assert_equal "foo", @scraper.results
    end
    
    should "build title from council name and result class" do
      assert_equal "Member scraper for Anytown council", @scraper.title
    end
    
    context "when getting data" do
      setup do
        #@scraper.stubs(:_http_get).returns
      end
    
      should "get url page" do
        @scraper.expects(:_http_get).with('http://www.anytown.gov.uk/members/bob').returns("something")
        @scraper.send(:_data)
      end
      
      should "return data as Hpricot Doc" do
        assert_kind_of Hpricot::Doc, @scraper.send(:_data)
      end
      
      # should "raise ReponseError when problem getting page" do
      #   @scraper.stubs(:_http_get).raises(HTTP::Error)
      #   assert_raise(ResponseError) {@scraper.send(:_data)}
      # end
      # 
      # should "raise ReponseError when problem processing page with Hpricot" do
      #   @scraper.stubs(:_http_get).returns("")
      #   assert_raise(ResponseError) {@scraper.send(:_data)}
      # end
    end
    
    context "when updating" do
      setup do
        @dummy_hpricot_data = stub
        @scraper.stubs(:_data).returns(@dummy_hpricot_data)
        @parser = stub(:process => { :foo => "bar" })
        @scraper.stubs(:parser).returns(@parser)
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
        @dummy_hpricot_data = stub
        Scraper.any_instance.stubs(:_data).returns(@dummy_hpricot_data)
        @parser = stub(:process => { :foo => "bar" })
        @scraper.stubs(:parser).returns(@parser)
      end
      
      should "process page" do
        @parser.expects(:process).with(@dummy_hpricot_data)
        @scraper.test
      end
      
      should "return self" do
        assert_equal @scraper, @scraper.test
      end
      
      context "processed result" do
        setup do
          Scraper.any_instance.stubs(:parser).returns(stub(:process => {:foo => "bar", :foo1 => 42}))
        end
        
        should "not have errors if no expected results to match against" do
          assert @scraper.test.errors.empty?
        end
       
        should "have errors if result class does not match expected_result_class" do
          assert_equal "was Array, but actual result class was Hash", new_scraper(:expected_result_class => "Array").test.errors[:expected_result_class]
        end

        should "have not have errors if result size does not match expected_result_size but expected_result_size is nil" do
          assert_nil new_scraper.test.errors[:expected_result_size]
        end
        
        should "have not have errors if result size does not match expected_result_size but result is not an array" do
          assert_nil new_scraper(:expected_result_size => 3).test.errors[:expected_result_size]
        end
        
        context "against expected_result_attributes" do
          should "have errors if it is missing required attribute" do
            assert_equal "weren't matched: :foobar expected but was missing or nil", new_scraper(:expected_result_attributes => ":foobar => true").test.errors[:expected_result_attributes]
          end
          
          should "not have errors if attribute requirements are met" do
            assert_nil new_scraper(:expected_result_attributes => ":foo => /ba/, :foo1 => Integer").test.errors[:expected_result_attributes]
          end
          
          should "have errors if attribute is wrong class" do
            assert_equal "weren't matched: :foo expected to be Integer but was String", new_scraper(:expected_result_attributes => ":foo => Integer").test.errors[:expected_result_attributes]
          end
          
          should "have errors if attribute does not match regexp" do
            assert_equal "weren't matched: :foo expected to match /baz/ but was 'bar'", new_scraper(:expected_result_attributes => ":foo => /baz/").test.errors[:expected_result_attributes]
          end
          
          should "have errors if attribute does not match multiple conditions" do
            expected_errors = ["weren't matched: :foo expected to match /baz/ but was 'bar'", "weren't matched: :foo1 expected to be String but was Fixnum"]
            errors = new_scraper(:expected_result_attributes => ":foo => /baz/, :foo1 => String").test.errors[:expected_result_attributes]
            assert_equal expected_errors.sort, errors.sort # so any problems with ordering is ignored
          end
          
          # decide what to do when attribute is missing -- i.e. should we say that if there's a k-v pair the key must exist, or should we say if it does exist it needs to match
        end
      end
      
      context "processed result array" do
        setup do
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
