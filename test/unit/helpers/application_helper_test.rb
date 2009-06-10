require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  context "link_for helper method" do

    should "return nil by default" do
      assert_nil link_for
    end
    
    should "return link for item with object title for link text" do
      obj = Factory(:committee) # poss better way of testing this. obj can be any ActiveRecord obj 
      assert_dom_equal link_to(obj.title, obj, :class => "committee_link"), link_for(obj)
    end
    
    should "escape object's title" do
      obj = Factory(:committee, :title => "something & nothing... which <needs> escaping" ) 
      assert_dom_equal link_to(h(obj.title), obj, :class => "committee_link"), link_for(obj)
    end
    
    should "pass on options" do
      obj = Factory(:committee, :title => "something & nothing... which <needs> escaping" ) 
      assert_dom_equal link_to(h(obj.title), obj, :foo => "bar", :class => "committee_link"), link_for(obj, :foo => "bar")
    end
    
    should "add given class to object class" do
      obj = Factory(:committee, :title => "something & nothing... which <needs> escaping" )
      assert_dom_equal link_to(h(obj.title), obj, :class => "committee_link bar"), link_for(obj, :class => "bar")
    end
  end
  
  context "council_page_for helper method" do

    should "return link based on url" do
      obj = stub(:url => "http://somecouncil/meeting")
      assert_dom_equal link_to("council page", "http://somecouncil/meeting", :class => "council_page_link external"), council_page_for(obj)
    end
  end
  
  context "link_to_api_url" do
    setup do
      @controller = TestController.new
      self.stubs(:params).returns(:controller => "councils", :action => "index")
    end

    should "should return xml link when xml requested" do
      assert_equal link_to("xml", { :controller => "councils", :action => "index", :format => "xml" }, :class => "api_link"), link_to_api_url("xml")
    end
    
    should "should return js link when json requested" do
      assert_equal link_to("json", { :controller => "councils", :action => "index", :format => "json" }, :class => "api_link"), link_to_api_url("json")
    end
    
  end
  
end