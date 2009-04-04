require 'test_helper'

class ScrapersControllerTest < ActionController::TestCase

  # index test
  context "on GET to :index" do
    setup do
      @scraper1 = Factory(:scraper)
      @scraper2 = Factory(:scraper_with_results)
      get :index
    end

    should_assign_to :scrapers
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    
    should "list all scrapers" do
      assert_select "#scrapers" do
        assert_select "li", 2
      end
    end
  end

  # show test
  context "on GET to :show for first record" do
    setup do
      @scraper = Factory(:scraper)
      Scraper.any_instance.expects(:test).never
      get :show, :id => @scraper.id
    end
  
    should_assign_to :scraper
    should_respond_with :success
    should_render_template :show
    
    should "show link to perform dry run" do
      assert_select "#scraper a", /perform test scrape/
    end
  
    should "show link to perform edit" do
      assert_select "#scraper a", /edit/
    end
  end
  
  context "on GET to :show with :dry_run" do
    setup do
      @scraper = Factory(:scraper)
    #   # Scraper.any_instance.stubs(:_http_get).returns("<p>some html</p>")
    #   # get :show, :id => 1, :dry_run => true
    end
      
    should "run test on scraper" do
      Scraper.any_instance.expects(:test).returns(stub_everything)
      get :show, :id => @scraper.id, :dry_run => true
    end
  end
  
  context "on GET to :show with succesful :dry_run" do
    setup do
      @scraper = Factory(:scraper_with_results)
      # @scraper.instance_variable_set(:@results, "something")
      # dummy_scraper = stub(:results => "something")
      Scraper.any_instance.expects(:test).returns(@scraper)
      get :show, :id => @scraper.id, :dry_run => true
    end
  
    should_assign_to :scraper, :results
    should_respond_with :success
    
    should "show summary of successful results" do
      assert_select "#results"
    end
  
    should "not show summary of problems" do
      assert_select "div.errorExplanation", false
    end
  end
  
  context "on GET to :show with unsuccesful :dry_run" do
    setup do
      @scraper = Factory(:scraper_with_errors)
      @scraper.instance_variable_set(:@results, "something")
      @scraper.errors.add_to_base("problems ahoy")
      # dummy_scraper = stub(:results => "something", :errors => {:base => "problems ahoy", :expected_result_size => "was 3, but actual result size was 2"})
      Scraper.expects(:find).returns(@scraper)
      Scraper.any_instance.expects(:test).returns(@scraper)
      get :show, :id => @scraper.id, :dry_run => true
    end
    
    should_assign_to :scraper, :results
    should_respond_with :success
    # 
    # should "show summary of problems" do
    #   assert_select "div.errorExplanation" do
    #     # assert_select
    #   end
    #   # assert_equal 1, assigns(:user).id
    #   # flunk("Failure message.")
    # end
  end
  
  # new test
  context "on GET to :new" do
    setup do
      @council = Factory(:council)
      get :new
    end
  
    should_assign_to :scraper
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
    should_render_a_form
      
    should "show select box for councils" do
      assert_select "select[name=?]", "scraper[council_id]"
    end
    
    should "show nested form for parser" do
      assert_select "textarea#scraper_parser_attributes_parsing_code"
    end
  end
  
  # create tests
  context "on POST to :create" do
    setup do
      @council = Factory(:council)
      post :create, { :scraper => { :council_id => @council.id, 
                                    :result_model => "Committee", 
                                    :url => "http://anytown.com/committees", 
                                    :parser_attributes => {:title => "new parser", :parsing_code => "some code"}}}
    end
    
    should_change "Scraper.count", :by => 1
    should_assign_to :scraper
    should_redirect_to( "the show page for scraper") { scraper_path(assigns(:scraper)) }
    should_set_the_flash_to "Successfully created scraper"
    
    should "description" do
      
    end
  end
  
  # edit tests
  context "on get to :edit a scraper" do
    
    setup do
      @scraper = Factory(:scraper)
      get :edit, :id => @scraper.id
    end
    
    should_assign_to :scraper
    should_respond_with :success
    should_render_template :edit
    should_not_set_the_flash
    should_render_a_form
    
    should "show nested form for parser " do
      assert_select "input[type=hidden][value=?]#scraper_parser_attributes_id", @scraper.parser.id
    end
  end
  
  # update tests
  context "on PUT to :update" do
    setup do
      @scraper = Factory(:scraper)
      put :update, { :id => @scraper.id, 
                     :scraper => { :council_id => @scraper.council_id, 
                                   :result_model => "Committee", 
                                   :url => "http://anytown.com/new_committees", 
                                   :parser_attributes => { :id => @scraper.parser.id, :title => "new parsing title", :parsing_code => "some code" }}}
    end
  
    should_assign_to :scraper
    should_redirect_to( "the show page for scraper") { scraper_path(@scraper) }
    should_set_the_flash_to "Successfully updated scraper"
    
    should "update scraper" do
      assert_equal "http://anytown.com/new_committees", @scraper.reload.url
    end
    
    should "update scraper parser" do
      assert_equal "new parsing title", @scraper.parser.reload.title
    end
  end
  
  
end
