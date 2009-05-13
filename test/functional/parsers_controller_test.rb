require 'test_helper'

class ParsersControllerTest < ActionController::TestCase
  
  # show tests
  context "on GET to :show for first record" do
    setup do
      @parser = Factory(:parser)
      get :show, :id => @parser.id
    end
  
    should_assign_to :parser
    should_respond_with :success
    should_render_template :show
      
    should "show link to perform edit" do
      assert_select ".parser a", /edit/
    end
  end
  
  # new tests
  context "on GET to :new" do
    setup do
      @portal_system = Factory(:portal_system)
    end

    context "with no portal_system given" do
      should "raise exception" do
        assert_raise(ArgumentError) { get :new }
      end
    end
    
    context "for basic parser" do
      setup do
        get :new, :portal_system_id  => @portal_system.id
      end
      
      should_assign_to(:parser)
      should_respond_with :success
      should_render_template :new

      should "show form" do
        assert_select "form#new_parser"
      end

      should "show include portal_system in hidden field" do
        assert_select "input#parser_portal_system_id[type=hidden][value=#{@portal_system.id}]"
      end
    end
    
  end
  
  # create test
   context "on POST to :create" do
     setup do
       @portal_system = Factory(:portal_system)
       @parser_params = Factory.attributes_for(:parser, :portal_system => @portal_system)
      end

       context "with valid params" do
         setup do
           post :create, :parser => @parser_params
         end

         should_change "Parser.count", :by => 1
         should_assign_to :parser
         should_redirect_to( "the show page for parser") { parser_path(assigns(:parser)) }
         should_set_the_flash_to "Successfully created parser"

       end
       
       context "with invalid params" do
         setup do
           post :create, :parser => @parser_params.except(:result_model)
         end

         should_not_change "Parser.count"
         should_assign_to :parser
         should_render_template :new
         should_not_set_the_flash
       end

   end  

  # edit tests
  context "on GET to :edit" do
    setup do
      @portal_system = Factory(:portal_system)
      @parser = Factory(:parser, :portal_system => @portal_system)
      get :edit, :id  => @parser.id
    end

    should_assign_to(:parser)
    should_respond_with :success
    should_render_template :edit
    
    should "show form" do
      assert_select "form#edit_parser_#{@parser.id}"
    end
    
  end
  
  # update test
  context "on PUT to :update" do
    setup do
      @portal_system = Factory(:portal_system)
      @parser = Factory(:parser, :portal_system => @portal_system)
      @parser_params = { :description => "New Description", 
                         :result_model => "Committee"}
     end


      context "with valid params" do
        setup do
          put :update, :id => @parser.id, :parser => @parser_params
        end

        should_not_change "Parser.count"
        should_change "@parser.reload.description", :to => "New Description"
        should_change "@parser.reload.result_model", :to => "Committee"
        should_assign_to :parser
        should_redirect_to( "the show page for parser") { parser_path(assigns(:parser)) }
        should_set_the_flash_to "Successfully updated parser"

      end

      context "with invalid params" do
        setup do
          put :update, :id => @parser.id, :parser => {:result_model => ""}
        end

        should_not_change "Parser.count"
        should_not_change "@parser.reload.result_model"
        should_assign_to :parser
        should_render_template :edit
        should_not_set_the_flash
      end

  end  
  
end
