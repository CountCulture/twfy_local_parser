require 'test_helper'

class CouncilsControllerTest < ActionController::TestCase

  def setup
    @member = Factory(:member)
    @council = @member.council
    @old_member = Factory(:old_member, :council => @council)
    @another_council = Factory(:another_council)
    @committee = Factory(:committee, :council => @council)
  end
  
  # index test
  context "on GET to :index" do
    
    context "with basic request" do
      setup do
        get :index
      end
  
      should_assign_to(:councils) { [@council]} # only parsed councils
      should_respond_with :success
      should_render_template :index
    end
    
    context "including unparsed councils" do
      setup do
        get :index, :include_unparsed => true
      end
  
      should_assign_to(:councils) { Council.find(:all, :order => "name")} # all councils
      should_respond_with :success
      should_render_template :index
      should "class unparsed councils as unparsed" do
        assert_select "#councils .unparsed", @another_council.name
      end
      should "class parsed councils as parsed" do
        assert_select "#councils .parsed", @council.name
      end
    end
    
    context "with xml requested" do
      setup do
        get :index, :format => "xml"
      end
  
      should_assign_to(:councils) { [@council]}
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/xml'
    end
    
    context "with json requested" do
      setup do
        get :index, :format => "json"
      end
  
      should_assign_to(:councils) { [@council]}
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/json'
    end
  end

  # show test
  context "on GET to :show " do
    
    context "with basic request" do
      setup do
        get :show, :id => @council.id
      end

      should_assign_to(:council) { @council}
      should_respond_with :success
      should_render_template :show
      should_assign_to(:members) { @council.members.current }

      should "list all members" do
        assert_select "#members li", @council.members.current.size
      end
      should "list all committees" do
        assert_select "#committees li", @council.committees.size
      end
    end
    
    context "with xml requested" do
      setup do
        get :show, :id => @council.id, :format => "xml"
      end

      should_assign_to(:council) { @council}
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/xml'
    end
    
    context "with json requested" do
      setup do
       get :show, :id => @council.id, :format => "json"
      end

      should_assign_to(:council) { @council}
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/json'
    end
    
    context "when council has datapoints" do
      setup do
        @datapoint = Factory(:datapoint, :council => @council)
        @dataset = @datapoint.dataset
        Council.any_instance.stubs(:datapoints).returns([@datapoint, @datapoint])
      end
      
      context "with summary" do
        setup do
          @datapoint.stubs(:summary => ["heading_1", "data_1"])
          get :show, :id => @council.id
        end
        
        should_assign_to :datapoints
        
        should "show datapoint data" do
          assert_select "#datapoints" do
            assert_select ".datapoint", 2 do
              assert_select "li", /data_1/
            end
          end
        end

        should "show links to full datapoint data" do
          assert_select "#datapoints" do
            assert_select "a.more_info[href*='datasets/#{@dataset.id}/data']"
          end
        end
      end
            
      context "without summary" do
        setup do
          @datapoint.stubs(:summary)
          get :show, :id => @council.id
        end
        
        should_assign_to(:datapoints) {[]}
        
        should "not show datapoint data" do
          assert_select "#datapoints", false
        end
      end

      context "with xml requested" do
        setup do
          @datapoint.stubs(:summary => ["heading_1", "data_1"])
          get :show, :id => @council.id, :format => "xml"
        end

        should "show associated datasets" do
          assert_select "council>datasets>dataset>id", @datapoint.dataset.id
        end
      end
      
      context "with json requested" do
        setup do
          @datapoint.stubs(:summary => ["heading_1", "data_1"])
          get :show, :id => @council.id, :format => "json"
        end

        should "show associated datasets" do
          assert_match /dataset.+#{@datapoint.dataset.title}/, @response.body
        end
      end
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

    should_assign_to(:council)
    should_respond_with :success
    should_render_template :new

    should "show form" do
      assert_select "form#new_council"
    end
    
    should "show possible portal_systems in form" do
      assert_select "select#council_portal_system_id"
    end
  end  

  # create test
   context "on POST to :create" do
     setup do
       @council_params = { :name => "Some Council", 
                           :url => "http://somecouncil.gov.uk"}
     end
     
     context "description" do
       setup do
         post :create, :council => @council_params
       end

       should_respond_with 401
     end
     
     context "with valid params" do
       setup do
         stub_authentication
         post :create, :council => @council_params
       end
     
       should_change "Council.count", :by => 1
       should_assign_to :council
       should_redirect_to( "the show page for council") { council_path(assigns(:council)) }
       should_set_the_flash_to "Successfully created council"
     
     end
     
     context "with invalid params" do
       setup do
         stub_authentication
         post :create, :council => @council_params.except(:name)
       end
     
       should_not_change "Council.count"
       should_assign_to :council
       should_render_template :new
       should_not_set_the_flash
     end
   end  

   # edit test
   context "on GET to :edit without auth" do
     setup do
       get :edit, :id => @council
     end

     should_respond_with 401
   end

   context "on GET to :edit with existing record" do
     setup do
       stub_authentication
       get :edit, :id => @council
     end

     should_assign_to(:council)
     should_respond_with :success
     should_render_template :edit

     should "show form" do
       assert_select "form#edit_council_#{@council.id}"
     end
   end  

  # update test
  context "on PUT to :update" do
    setup do
      @council_params = { :name => "New Name for SomeCouncil", 
                          :url => "http://somecouncil.gov.uk/new"}
    end
    
    context "without auth" do
      setup do
        put :update, :id => @council.id, :council => @council_params
      end

      should_respond_with 401
    end
    
    context "with valid params" do
      setup do
        stub_authentication
        put :update, :id => @council.id, :council => @council_params
      end
    
      should_not_change "Council.count"
      should_change "@council.reload.name", :to => "New Name for SomeCouncil"
      should_change "@council.reload.url", :to => "http://somecouncil.gov.uk/new"
      should_assign_to :council
      should_redirect_to( "the show page for council") { council_path(assigns(:council)) }
      should_set_the_flash_to "Successfully updated council"
    
    end
    
    context "with invalid params" do
      setup do
        stub_authentication
        put :update, :id => @council.id, :council => {:name => ""}
      end
    
      should_not_change "Council.count"
      should_not_change "@council.reload.name"
      should_assign_to :council
      should_render_template :edit
      should_not_set_the_flash
    end

  end  

end
