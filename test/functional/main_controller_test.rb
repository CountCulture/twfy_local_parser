require 'test_helper'

class MainControllerTest < ActionController::TestCase
  context "on GET to :index" do
    setup do
      @council1 = Factory(:council)
      @council2 = Factory(:another_council)
      @member = Factory(:member, :council => @council1)
      get :index
    end
  
    should_assign_to :councils
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    
    should "list latest parsed councils" do
      assert_select "#latest_councils" do
        assert_select "li", 1 do # only #council1 has members and therefore is considered parsed
          assert_select "a", @council1.title
        end
      end
    end
  end
end
