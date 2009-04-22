require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  context "link_for helper method" do

    should "return nil by default" do
      assert_nil link_for
    end
    
    should "return link for item with object title for link text" do
      obj = Factory(:committee) # poss better way of testing this. obj can be any ActiveRecord obj 
      assert_equal link_to(obj.title, obj), link_for(obj)
    end
    
    should "escape object's title" do
      obj = Factory(:committee, :title => "something & nothing... which <needs> escaping" ) 
      assert_equal link_to(h(obj.title), obj), link_for(obj)
    end
  end
  
end