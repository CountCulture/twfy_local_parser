require 'test_helper'

class GlaScraperTest < Test::Unit::TestCase

  context "A Gla scraper" do
    
    setup do
      @scraper = Gla::Scraper.new(:target_page => "lams_facts_cont.jsp")
    end

    should "have a base url" do
      assert_equal "http://www.london.gov.uk/assembly/", @scraper.base_url
    end
    
    should "have a target url" do
      assert_equal "lams_facts_cont.jsp", @scraper.target_page
    end
    
    should "get response to using base_url and target page" do
      
      @scraper.expects(:_http_get).with("http://www.london.gov.uk/assembly/lams_facts_cont.jsp").returns("some response")
      @scraper.response
    end
    
    should "return Hpricot Doc object as response" do
      @scraper.stubs(:_http_get).with("http://www.london.gov.uk/assembly/lams_facts_cont.jsp").returns("some response")
      assert_kind_of Hpricot::Doc, @scraper.response
    end
  end
  
  context "A GlaMembersScraper" do
    setup do
      @members_scraper = Gla::MembersScraper.new(:target_page => "/assembly/lams_facts_cont.jsp")
      Gla::MembersScraper.any_instance.stubs(:_http_get).returns(dummy_response(:members_list))
    end

    should "inherit from Gla scraper" do
      assert_equal Gla::Scraper, @members_scraper.class.superclass
    end
    
    should "return array from response" do
      assert_kind_of Array, @members_scraper.response
    end
    
    should "return array with same number of elements as number of members" do
      assert_equal 25, @members_scraper.response.size
    end
    
    context "response array element" do
      setup do
        @response_element = @members_scraper.response.first
      end

      should "be a Member" do
        assert_kind_of Member, @response_element
      end
      
      should "have parsed members name" do
        assert_equal "Brian Coleman", @response_element.full_name
      end
      
      should "have parsed members constituency" do
        assert_equal "Barnet & Camden", @response_element.constituency
      end
      
      should "have parsed members party" do
        assert_equal "Conservative", @response_element.party
      end
      
      should "have parsed members url" do
        assert_equal "members/colemanb.jsp", @response_element.url
      end
      
    end
    
    context "response array element without constiuency" do
      setup do
        @response_element = @members_scraper.response.last
      end

      should "be a Member" do
        assert_kind_of Member, @response_element
      end
      
      should "have parsed members name" do
        assert_equal "Mike Tuffrey", @response_element.full_name
      end
      
      should "have parsed members constituency" do
        assert_nil @response_element.constituency
      end
      
      should "have parsed members party" do
        assert_equal "Liberal Democrat", @response_element.party
      end
      
      should "have parsed members url" do
        assert_equal "members/tuffreym.jsp", @response_element.url
      end
      
    end
    
  end
  
  context "A GlaMemberScraper" do
    setup do
      @member_scraper = Gla::MemberScraper.new(:target_page => "malthousek.jsp")
      Gla::MemberScraper.any_instance.stubs(:_http_get).returns(dummy_response(:member_details))
    end

    should "inherit from Gla scraper" do
      assert_equal Gla::Scraper, @member_scraper.class.superclass
    end
    
    context "response" do
      setup do
        @response = @member_scraper.response
      end

      should "be a Member" do
        assert_kind_of Member, @response
      end
      
      should "have parsed email address" do
        assert_equal "kit.malthouse@london.gov.uk", @response.email
      end
      
      should "have parsed telephone" do
        assert_equal "020 7983 4099", @response.telephone
      end
    end
        
  end
  
  
  private
  def dummy_response(response_name)
    IO.read(File.join([RAILS_ROOT + "/test/fixtures/dummy_responses/#{response_name.to_s}.html"]))
  end
end
