require 'test_helper'

class PortalSystemsControllerTest < ActionController::TestCase

  def setup
    @portal = Factory(:portal_system)
  end
  
  # index test
  context "on GET to :index without auth" do
    setup do
      get :index
    end
  
    should_respond_with 401
  end

  context "on GET to :index" do
    setup do
      stub_authentication
      get :index
    end
  
    should_assign_to(:portal_systems) { PortalSystem.find(:all)}
    should_respond_with :success
    should_render_template :index
    should "list portal systems" do
      assert_select "li a", @portal.name
    end
    
    should "not show share block" do
      assert_select "#share_block", false
    end
  end  

  # show test
  context "on GET to :show without auth" do
    setup do
      get :show, :id => @portal.id
    end
  
    should_respond_with 401
  end

  context "on GET to :show for first record" do
    setup do
      @council = Factory(:council, :portal_system_id => @portal.id)
      @parser = Factory(:parser, :portal_system => @portal)
      stub_authentication
      get :show, :id => @portal.id
    end
  
    should_assign_to(:portal_system) { @portal}
    should_respond_with :success
    should_render_template :show
    should_assign_to(:councils) { @portal.councils }
  
    should "list all councils" do
      assert_select "#councils li", @portal.councils.size do
        assert_select "a", @council.title
      end
    end
    
    should "list all parsers" do
      assert_select "#parsers li" do
        assert_select "a", @parser.title
      end
    end
    
    should "not show share block" do
      assert_select "#share_block", false
    end
  end  
  
  # new test
  context "on GET to :new without auth" do
    setup do
      get :new
    end
  
    should_respond_with 401
  end

  context "on GET to :new" do
    setup do
      stub_authentication
      get :new
    end
  
    should_assign_to(:portal_system)
    should_respond_with :success
    should_render_template :new
  
    should "show form" do
      assert_select "form#new_portal_system"
    end
  end  
  
  # create test
   context "on POST to :create" do
    
     context "without auth" do
       setup do
         post :create, :portal_system => {:name => "New Portal", :url => "http:://new_portal.com"}
       end

       should_respond_with 401
     end

     context "with valid params" do
       setup do
         stub_authentication
         post :create, :portal_system => {:name => "New Portal", :url => "http:://new_portal.com"}
       end
     
       should_change "PortalSystem.count", :by => 1
       should_assign_to :portal_system
       should_redirect_to( "the show page for portal_system") { portal_system_path(assigns(:portal_system)) }
       should_set_the_flash_to "Successfully created portal system"
     
     end
     
     context "with invalid params" do
       setup do
         stub_authentication
         post :create, :portal_system => {:url => "http:://new_portal.com"}
       end
     
       should_not_change "PortalSystem.count"
       should_assign_to :portal_system
       should_render_template :new
       should_not_set_the_flash
     end
  
   end  
  
   # edit test
   context "on GET to :edit without auth" do
     setup do
       get :edit, :id => @portal
     end

     should_respond_with 401
   end

   context "on GET to :edit with existing record" do
     setup do
       stub_authentication
       get :edit, :id => @portal
     end
  
     should_assign_to(:portal_system)
     should_respond_with :success
     should_render_template :edit
  
     should "show form" do
       assert_select "form#edit_portal_system_#{@portal.id}"
     end
   end  
  
  # update test
  context "on PUT to :update" do
    context "without auth" do
      setup do
        put :update, :id => @portal.id, :portal_system => { :name => "New Name", :url => "http://new.name.com"}
      end

      should_respond_with 401
    end
    
    context "with valid params" do
      setup do
        stub_authentication
        put :update, :id => @portal.id, :portal_system => { :name => "New Name", :url => "http://new.name.com"}
      end
    
      should_not_change "PortalSystem.count"
      should_change "@portal.reload.name", :to => "New Name"
      should_change "@portal.reload.url", :to => "http://new.name.com"
      should_assign_to :portal_system
      should_redirect_to( "the show page for portal system") { portal_system_path(assigns(:portal_system)) }
      should_set_the_flash_to "Successfully updated portal system"
    
    end
    
    context "with invalid params" do
      setup do
        stub_authentication
        put :update, :id => @portal.id, :portal_system => {:name => ""}
      end
    
      should_not_change "PortalSystem.count"
      should_not_change "@portal.reload.name"
      should_assign_to :portal_system
      should_render_template :edit
      should_not_set_the_flash
    end
  
  end  

end
