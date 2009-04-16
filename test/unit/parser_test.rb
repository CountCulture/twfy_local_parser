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
    # should "save raw response as instance variable" do
    #   @dummy_hpricot = stub_everything
    #   @parser.process(@dummy_hpricot)
    #   assert_equal @dummy_hpricot, @parser.instance_variable_get(:@raw_response)
    # end
    
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
