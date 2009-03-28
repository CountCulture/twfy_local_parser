require 'test_helper'

class ParserTest < Test::Unit::TestCase
  should_validate_presence_of :parsing_code
  should_validate_presence_of :title
  should_have_many :scrapers
  
  context "The Parser class" do
    
  end
  
  context "A Parser instance" do
    
    setup do
      @dummy_content = "Some dummy content"
      @parser = Parser.new(:title => "Dummy Parser", :parsing_code => "some dummy code")
      @dummy_hpricot = stub_everything
      Hpricot.stubs('()'.to_sym).returns(@dummy_hpricot)
    end

    should "process first parse content with Hpricot" do
      Hpricot.expects('()'.to_sym).with(@dummy_content)
      @parser.process(@dummy_content)
    end
    
    should "process hpricot doc with parsing code" do
      Parser.expects(:instance_eval).with("some dummy code", @dummy_hpricot)
      @parser.process(@dummy_content)
    end
    
    should "provide hpricot as instance variable to parsing code" do
      assert flunk
    end
    
    #should "return nil_for target page if none given and TARGET_PAGE not defined" do
      #assert_nil Gla::Scraper.new.target_page
    #end
    
    #should "get response to using base_url and target page" do
      #@scraper.expects(:_http_get).with("http://www.london.gov.uk/assembly/lams_facts_cont.jsp").returns("some response")
      #@scraper.response
    #end
    
    #should "return Hpricot Doc object as response" do
      #@scraper.stubs(:_http_get).with("http://www.london.gov.uk/assembly/lams_facts_cont.jsp").returns("some response")
      #assert_kind_of Hpricot::Doc, @scraper.response
    #end
  end
  

  private
  def dummy_response(response_name)
    IO.read(File.join([RAILS_ROOT + "/test/fixtures/dummy_responses/#{response_name.to_s}.html"]))
  end
end
