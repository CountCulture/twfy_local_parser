require 'test_helper'

class ParserTest < Test::Unit::TestCase
  should_validate_presence_of :parsing_code
  should_validate_presence_of :title
  should_have_many :scrapers
  
  context "The Parser class" do
    
  end
  
  context "A Parser instance" do
    
    setup do
      @parser = Factory.create(:parser)
      @dummy_hpricot = stub_everything
    end
    
    should "save raw response as instance variable" do
      @parser.process(@dummy_hpricot)
      assert_equal @dummy_hpricot, @parser.instance_variable_get(:@raw_response)
    end
    
    context "when processing" do

      should "process hpricot doc with parsing code" do
        @parser.expects(:instance_eval).with('foo="bar"')
        @parser.process(@dummy_hpricot)
      end
      
      # should "provide hpricot as instance variable to parsing code" do
        # assert_equal @dummy_hpricot, @parser.instance_variable_get(:@doc)
      # end

      should "return self" do
        assert_equal @parser, @parser.process(@dummy_hpricot)
      end
      
      should "save results of parsing in results instance variable" do
        @parser.stubs(:instance_eval).returns("some results")
        @parser.process(@dummy_hpricot)
        assert_equal "some results", @parser.instance_variable_get(:@results)
      end
      
      context "and problems occur" do
        setup do
          @dummy_hpricot_for_problem_parser = Hpricot("some text")
          @problem_parser = Parser.new(:parsing_code => "foo + bar")
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
