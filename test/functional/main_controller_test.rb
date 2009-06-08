require 'test_helper'

class MainControllerTest < ActionController::TestCase
  context "on GET to :index" do
    setup do
      @council1 = Factory(:council)
      @council2 = Factory(:another_council)
      get :index
    end
  
    should_assign_to :councils
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    
    should "list all councils" do
      assert_select "#latest_councils" do
        assert_select "li a", 2
      end
    end
  end
end
