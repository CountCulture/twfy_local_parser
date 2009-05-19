require 'test_helper'

class ParserTest < Test::Unit::TestCase
  
  context "The Parser class" do
    should_have_many :scrapers
    should_belong_to :portal_system
    should_validate_presence_of :result_model
    should_validate_presence_of :scraper_type
    should_allow_values_for :result_model, "Member", "Committee", "Meeting"
    should_not_allow_values_for :result_model, "foo", "User"
    should_allow_values_for :scraper_type, "InfoScraper", "ItemScraper"
    should_not_allow_values_for :scraper_type, "foo", "OtherScraper"

    should "serialize attribute_parser" do
      parser = Parser.create!(:description => "description of parser", :item_parser => "foo", :scraper_type => "ItemScraper", :attribute_parser => {:foo => "\"bar\"", :foo2 => "nil"}, :result_model => "Member")
      assert_equal({:foo => "\"bar\"", :foo2 => "nil"}, parser.reload.attribute_parser)
    end
    
  end
  
  context "A Parser instance" do
    setup do
      PortalSystem.delete_all # some reason not getting rid of old records -- poss 2.3.2 bug (see Caboose blog)
      @parser = Factory(:parser)
    end
    
    context "in general" do
      should "have results accessor" do
        @parser.instance_variable_set(:@results, "foo")
        assert_equal "foo", @parser.results
      end

      should "return details as title" do
        assert_equal "Member item parser for single scraper only", @parser.title
      end
      
      should "return details as title when new parser" do
        assert_equal "Committee item parser for single scraper only", Parser.new(:result_model => "Committee", :scraper_type => "ItemScraper").title
      end
    end
    
    context "that is associated with portal system" do
      setup do
        @portal_system_for_parser = Factory(:portal_system, :name => "Portal for Parser")
        @parser.update_attribute(:portal_system_id, @portal_system_for_parser.id)
      end

      should "return details of portal_system in title" do
        assert_equal "Member item parser for Portal for Parser", @parser.title
      end
    end
        
    context "with attribute_parser has attribute_parser_object which" do
      setup do
        @attribute_parser_object = @parser.attribute_parser_object
      end
      
      should "be an Array" do
        assert_kind_of Array, @attribute_parser_object
      end
      
      should "be same size as attribute_parser" do
        assert_equal @parser.attribute_parser.keys.size, @attribute_parser_object.size
      end
      
      context "has elements which" do
        setup do
          @first_attrib = @attribute_parser_object.first
        end

        should "are Structs" do
          assert_kind_of Struct, @first_attrib
        end
        
        should "make attribute_parser_key accessible as attrib_name" do
          assert_equal "foo", @first_attrib.attrib_name
        end

        should "make attribute_parser_value accessible as parsing_code" do
          assert_equal "\"bar\"", @first_attrib.parsing_code
        end
      end
      
      context "when attribute_parser is blank" do
        setup do
          @empty_attribute_parser_object = Parser.new.attribute_parser_object
        end

        should "be an Array" do
          assert_kind_of Array, @empty_attribute_parser_object
        end

        should "with one element" do
          assert_equal 1, @empty_attribute_parser_object.size
        end
        
        should "is an empty Struct" do
          assert_equal Parser::AttribObject.new, @empty_attribute_parser_object.first
        end
      end
      
    end
    
    context "when given attribute_parser info from form params" do
      
      should "convert to attribute_parser hash" do
        @parser.attribute_parser_object = [{ "attrib_name" => "title",
                                             "parsing_code" => "parsing code for title"},
                                           { "attrib_name" => "description",
                                             "parsing_code" => "parsing code for description"}]
        assert_equal({ :title => "parsing code for title", :description => "parsing code for description" }, @parser.attribute_parser)
      end
      
      should "set attribute_parser to empty hash if no form_params" do
        @parser.attribute_parser_object = []
        assert_equal({}, @parser.attribute_parser)
      end
    end
 
    context "when evaluating parsing code" do
      should "evaluate code" do
        @parser.expects(:eval).with("some code")
        @parser.send(:eval_parsing_code, "some code", "foo")
      end
      
      should "return result" do
        @parser.stubs(:eval).with("some code").returns("some return value")
        assert_equal "some return value", @parser.send(:eval_parsing_code, "some code", "foo")
      end
      
      should "make given object available as 'item' local variable" do
        given_obj = stub
        assert_equal given_obj, @parser.send(:eval_parsing_code, "item", given_obj) # will raise exception unless item local variable exists
      end
    end
    
    context "when processing" do
      
      context "in general" do
        setup do
          @dummy_hpricot = stub_everything
          @parser.stubs(:eval_parsing_code)
        end

        should "return self" do
          assert_equal @parser, @parser.process(@dummy_hpricot)
        end

        should "eval item_parser code on hpricot doc" do
          @parser.expects(:eval_parsing_code).with('foo="bar"', @dummy_hpricot )
          @parser.process(@dummy_hpricot)
        end
        
        should "eval attribute_parser code on hpricot doc if no item_parser" do
          no_item_parser_parser = Factory.build(:parser, :item_parser => nil)
          dummy_hpricot = mock
          no_item_parser_parser.expects(:eval_parsing_code).with(){ |code, item| (code =~ /bar/) && (item == dummy_hpricot) }
          no_item_parser_parser.process(dummy_hpricot)
        end
      end
      
      
      context "and single item is returned" do
        setup do
          @dummy_item = stub
          @dummy_hpricot = stub
          @parser.stubs(:eval_parsing_code).with(@parser.item_parser, @dummy_hpricot).returns(@dummy_item)
        end
      
        should "evaluate each attribute_parser on item" do
          @parser.expects(:eval_parsing_code).twice.with(){ |code, item| (code =~ /bar/)&&(item == @dummy_item) }
          @parser.process(@dummy_hpricot)
        end
        
        should "store result of attribute_parser as hash using attribute_parser keys" do
          @parser.expects(:eval_parsing_code).twice.with(){ |code, item| (code =~ /bar/)&&(item == @dummy_item) }.returns("some value")
          assert_equal ([{:foo => "some value", :foo1 => "some value"}]), @parser.process(@dummy_hpricot).results
        end
      end
            
      context "and array of items is returned" do
        setup do
          @dummy_item_1, @dummy_item_2 = stub, stub
          @dummy_hpricot = stub
          @parser.stubs(:eval_parsing_code).with(@parser.item_parser, @dummy_hpricot).returns([@dummy_item_1, @dummy_item_2])
        end
      
        should "evaluate each attribute_parser value on item" do
          @parser.expects(:eval_parsing_code).twice.with(){ |code, item| (code =~ /bar/)&&(item == @dummy_item_1) }
          @parser.expects(:eval_parsing_code).twice.with(){ |code, item| (code =~ /bar/)&&(item == @dummy_item_2) }
          @parser.process(@dummy_hpricot)
        end
        
        should "store result of attribute_parser as hash using attribute_parser keys" do
          @parser.stubs(:eval_parsing_code).with(){ |code, item| (code =~ /bar/)&&(item == @dummy_item_1) }.returns("some value")
          @parser.stubs(:eval_parsing_code).with(){ |code, item| (code =~ /bar/)&&(item == @dummy_item_2) }.returns("another value")
          assert_equal ([{ :foo => "some value", :foo1 => "some value" },
                         { :foo => "another value", :foo1 => "another value" }]), @parser.process(@dummy_hpricot).results
        end
      end
            
      context "and problems occur when parsing items" do
        setup do
          @dummy_hpricot_for_problem_parser = Hpricot("some text")
          @problem_parser = Parser.new(:item_parser => "foo + bar")
        end
      
        should "not raise exception" do
          assert_nothing_raised() { @problem_parser.process(@dummy_hpricot_for_problem_parser) }
        end
        
        should "return self" do
          assert_equal @problem_parser, @problem_parser.process(@dummy_hpricot_for_problem_parser)
        end
        
        should "store errors in parser" do
          errors = @problem_parser.process(@dummy_hpricot_for_problem_parser).errors[:base]
          assert_match /Exception raised.+parsing items/, errors
          assert_match /Problem .+parsing code .+foo \+ bar/, errors
          assert_match /Hpricot.+#{@dummy_hpricot_for_problem_parser.inspect}/, errors
        end
        
      end
      
      context "and problems occur when parsing attributes" do
        setup do
          @dummy_item_1, @dummy_item_2 = "String_1", "String_2"
          @dummy_hpricot_for_attrib_prob = stub
          @problem_parser = Parser.new(:item_parser => "#nothing here", :attribute_parser => {:full_name => "foobar"}) # => unknown local variable
          @problem_parser.stubs(:eval_parsing_code).with("#nothing here", @dummy_hpricot_for_attrib_prob).returns([@dummy_item_1, @dummy_item_2])
        end
      
        should "not raise exception" do
          assert_nothing_raised() { @problem_parser.process(@dummy_hpricot_for_attrib_prob) }
        end
        
        should "return self" do
          assert_equal @problem_parser, @problem_parser.process(@dummy_hpricot_for_attrib_prob)
        end
        
        should "store errors in parser" do
          errors = @problem_parser.process(@dummy_hpricot_for_attrib_prob).errors[:base]
          assert_match /Exception raised.+parsing attributes/, errors
          assert_match /Problem .+parsing code .+foobar/, errors
          assert_match /Hpricot.+#{@dummy_item_1.inspect}/, errors
        end
        
      end
    end 
  end
  

  private
  def dummy_response(response_name)
    IO.read(File.join([RAILS_ROOT + "/test/fixtures/dummy_responses/#{response_name.to_s}.html"]))
  end
end
