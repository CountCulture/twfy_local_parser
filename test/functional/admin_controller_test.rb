require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  
  context "on GET to :index" do
    context "with authentication" do
      setup do
        stub_authentication
        get :index
      end

      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash

      should "show admin in title" do
        assert_select "title", /admin/i
      end
    end 
    
    context "without authentication" do
      setup do
        get :index
      end

      should_respond_with 401
    end
    
  end
end
