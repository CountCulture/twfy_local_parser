require 'test_helper'

class ParserTest < Test::Unit::TestCase
  
  context "The Parser class" do
    should_validate_presence_of :item_parser
    should_validate_presence_of :title
    should_have_many :scrapers

    should "serialize attribute_parser" do
      parser = Parser.create!(:title => "test parser", :item_parser => "foo", :attribute_parser => {:foo => "\"bar\"", :foo2 => "nil"})
      assert_equal({:foo => "\"bar\"", :foo2 => "nil"}, parser.reload.attribute_parser)
    end
  end
  
  context "A Parser instance" do
    setup do
      @parser = Factory.create(:parser)
    end
    
    should "have results accessor" do
      @parser.instance_variable_set(:@results, "foo")
      assert_equal "foo", @parser.results
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
 
    context "when processing" do
      
      context "in general" do
        setup do
          @dummy_hpricot = stub_everything
        end

        should "return self" do
          assert_equal @parser, @parser.process(@dummy_hpricot)
        end

        should "evaluate item_parser code in contect of hpricot doc" do
          @dummy_hpricot.expects(:instance_eval).with('foo="bar"')
          @parser.process(@dummy_hpricot)
        end
        
      end
      
      
      context "and single item is returned" do
        setup do
          @dummy_item = stub
          @dummy_hpricot = stub(:instance_eval => @dummy_item)
        end
      
        should "evaluate each attribute_parser value on item in context of item" do
          @dummy_item.expects(:instance_eval).twice.with(){ |value| value =~ /bar/ }
          @parser.process(@dummy_hpricot)
        end
        
        should "store result of attribute_parser as hash using attribute_parser keys" do
          @dummy_item.stubs(:instance_eval).returns("some value")
          assert_equal ([{:foo => "some value", :foo1 => "some value"}]), @parser.process(@dummy_hpricot).results
        end
      end
            
      context "and array of items is returned" do
        setup do
          @dummy_item_1, @dummy_item_2 = stub, stub
          @dummy_hpricot = stub(:instance_eval => [@dummy_item_1, @dummy_item_2])
        end
      
        should "evaluate each attribute_parser value on item in context of item" do
          @dummy_item_1.expects(:instance_eval).twice.with(){ |value| value =~ /bar/ }
          @dummy_item_2.expects(:instance_eval).twice.with(){ |value| value =~ /bar/ }
          @parser.process(@dummy_hpricot)
        end
        
        should "store result of attribute_parser as hash using attribute_parser keys" do
          @dummy_item_1.stubs(:instance_eval).returns("some value")
          @dummy_item_2.stubs(:instance_eval).returns("another value")
          assert_equal ([{ :foo => "some value", :foo1 => "some value" },
                         { :foo => "another value", :foo1 => "another value" }]), @parser.process(@dummy_hpricot).results
        end
      end
            
      context "and problems occur" do
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
          assert_match /Exception raised/, @problem_parser.process(@dummy_hpricot_for_problem_parser).errors[:base]
        end
        
      end
    end 
  end
  

  private
  def dummy_response(response_name)
    IO.read(File.join([RAILS_ROOT + "/test/fixtures/dummy_responses/#{response_name.to_s}.html"]))
  end
end
