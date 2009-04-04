require 'test_helper'

class ParserTest < Test::Unit::TestCase
  should_validate_presence_of :parsing_code
  should_validate_presence_of :title
  should_have_many :scrapers
  
  context "The Parser class" do
    
  end
  
  context "A Parser instance" do
    
    setup do
      @parser = Factory.new(:parser)
      @dummy_hpricot = stub_everything
    end
    
    should "process hpricot doc with parsing code" do
      # Parser.expects(:instance_eval).with("some dummy code", @dummy_hpricot)
      # @parser.process(@dummy_hpricot)
    end
    
    should "provide hpricot as instance variable to parsing code" do
      # assert_equal @dummy_hpricot, @parser.instance_variable_get(:@doc)
    end
    
  end
  

  private
  def dummy_response(response_name)
    IO.read(File.join([RAILS_ROOT + "/test/fixtures/dummy_responses/#{response_name.to_s}.html"]))
  end
end
