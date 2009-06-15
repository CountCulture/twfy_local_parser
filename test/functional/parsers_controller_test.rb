require 'test_helper'

class ParsersControllerTest < ActionController::TestCase
  
  # show tests
  context "on GET to :show without auth" do
    setup do
      @parser = Factory(:parser)
      @scraper = Factory(:scraper, :parser => @parser)
      get :show, :id => @parser.id
    end
  
    should_respond_with 401
  end

  context "on GET to :show" do
    setup do
      @parser = Factory(:parser)
      @scraper = Factory(:scraper, :parser => @parser)
      stub_authentication
      get :show, :id => @parser.id
    end
  
    should_assign_to :parser
    should_assign_to :scrapers
    should_respond_with :success
    should_render_template :show
      
    should "show link to perform edit" do
      assert_select ".parser a", /edit/
    end
    
    should "list associated scrapers" do
      assert_select "#scrapers a", @scraper.title
    end
    
    should "show related model field" do
      assert_select ".parser strong", /related/i
    end
  end
  
  context "on GET to :show for InfoScraper parser" do
    setup do
      @parser = Factory(:another_parser)
      @scraper = Factory(:scraper, :parser => @parser)
      stub_authentication
      get :show, :id => @parser.id
    end
  
    should_assign_to :parser
    should_assign_to :scrapers
    should_respond_with :success
    should_render_template :show
    
    should "list associated scrapers" do
      assert_select "#scrapers a", @scraper.title
    end
      
    should "not show related model field" do
      assert_select ".parser strong", :text => /related/i, :count => 0
    end
  end
  # new tests
  context "on GET to :new" do
    setup do
      @portal_system = Factory(:portal_system)
    end
    
    context "with no portal_system given" do
      should "raise exception" do
        stub_authentication
        assert_raise(ArgumentError) { get :new, :result_model => "Member", :scraper_type => "ItemParser" }
      end
    end
    
    context "with no scraper_type given" do
      should "raise exception" do
        stub_authentication
        assert_raise(ArgumentError) { get :new, :portal_system_id  => @portal_system.id, :result_model => "Member" }
      end
    end
    
    context "without auth" do
      setup do
        get :new, :portal_system_id  => @portal_system.id, :result_model => "Member", :scraper_type => "ItemParser"
      end
      should_respond_with 401
    end
    
    context "for basic parser" do
      setup do
        stub_authentication
        get :new, :portal_system_id  => @portal_system.id, :result_model => "Member", :scraper_type => "ItemParser"
      end
      
      should_assign_to(:parser)
      should_respond_with :success
      should_render_template :new

      should "show form" do
        assert_select "form#new_parser"
      end

      should "include portal_system in hidden field" do
        assert_select "input#parser_portal_system_id[type=hidden][value=#{@portal_system.id}]"
      end
      
      should "include scraper_type in hidden field" do
        assert_select "input#parser_scraper_type[type=hidden][value='ItemParser']"
      end
    end
    
  end
  
  # create test
   context "on POST to :create" do
     setup do
       @portal_system = Factory(:portal_system)
       @parser_params = Factory.attributes_for(:parser, :portal_system => @portal_system)
      end
      
      context "without auth" do
        setup do
          post :create, :parser => @parser_params
        end

        should_respond_with 401
      end
      
       context "with valid params" do
         setup do
           stub_authentication
           post :create, :parser => @parser_params
         end

         should_change "Parser.count", :by => 1
         should_assign_to :parser
         should_redirect_to( "the show page for parser") { parser_path(assigns(:parser)) }
         should_set_the_flash_to "Successfully created parser"

       end
       
       context "with invalid params" do
         setup do
           stub_authentication
           post :create, :parser => @parser_params.except(:result_model)
         end

         should_not_change "Parser.count"
         should_assign_to :parser
         should_render_template :new
         should_not_set_the_flash
       end

       context "with no scraper_type" do
         setup do
           stub_authentication
           post :create, :parser => @parser_params.except(:scraper_type)
         end

         should_not_change "Parser.count"
         should_assign_to :parser
         should_render_template :new
         should_not_set_the_flash
       end

   end  

  # edit tests
  context "on GET to :edit without auth" do
    setup do
      @portal_system = Factory(:portal_system)
      @parser = Factory(:parser, :portal_system => @portal_system)
      get :edit, :id  => @parser.id
    end
  
    should_respond_with 401
  end

  context "on GET to :edit" do
    setup do
      @portal_system = Factory(:portal_system)
      @parser = Factory(:parser, :portal_system => @portal_system)
      stub_authentication
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
                         :result_model => "Committee",
                         :item_parser => "foo=\"new_bar\"",
                         :attribute_parser_object => [{:attrib_name => "newfoo", :parsing_code => "barbar"}]}
     end

     context "wihtout auth" do
       setup do
         put :update, :id => @parser.id, :parser => @parser_params
       end

       should_respond_with 401
     end
     
      context "with valid params" do
        setup do
          stub_authentication
          put :update, :id => @parser.id, :parser => @parser_params
        end

        should_not_change "Parser.count"
        should_change "@parser.reload.description", :to => "New Description"
        should_change "@parser.reload.result_model", :to => "Committee"
        should_change "@parser.reload.item_parser", :to => "foo=\"new_bar\""
        should_change "@parser.reload.attribute_parser", :to => {:newfoo => "barbar"}
        should_assign_to :parser
        should_redirect_to( "the show page for parser") { parser_path(assigns(:parser)) }
        should_set_the_flash_to "Successfully updated parser"

      end

      context "with invalid params" do
        setup do
          stub_authentication
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
