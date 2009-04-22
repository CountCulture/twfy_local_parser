require 'test_helper'

class ScrapersControllerTest < ActionController::TestCase

  # index test
  context "on GET to :index" do
    setup do
      @scraper1 = Factory(:scraper)
      @scraper2 = Factory(:info_scraper)
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
      @scraper.class.any_instance.expects(:test).never
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
    end
      
    should "run process scraper" do
      @scraper.class.any_instance.expects(:process).returns(stub_everything)
      get :show, :id => @scraper.id, :dry_run => true
    end
  end
  
  context "on GET to :show with successful :dry_run" do
    setup do
      @scraper = Factory(:scraper)
      @member = Factory(:member, :council => @scraper.council)
      @member.save # otherwise looks like new_before_save
      @new_member = Member.new(:full_name => "Fred Flintstone", :uid => 55)
      @scraper.class.any_instance.stubs(:process).returns(@scraper)
      @scraper.stubs(:results).returns([@member, @new_member])
      get :show, :id => @scraper.id, :dry_run => true
    end
  
    should_assign_to :scraper, :results
    should_respond_with :success
    
    should "show summary of successful results" do
      assert_select "#results" do
        assert_select "div.member", 2 do
          assert_select "h4", /#{@member.full_name}/
          assert_select "div.new", 1 do
            assert_select "h4", /Fred Flintstone/
          end
        end
      end
    end
  
    should "not show summary of problems" do
      assert_select "div.errorExplanation", false
    end
  end
  
  context "on GET to :show with :dry_run with parsing problems" do
    setup do
      @scraper = Factory(:scraper)
      @scraper.class.any_instance.stubs(:_data).returns(stub_everything)
      parser = @scraper.parser
      parser.stubs(:results) # pretend there are no results
      parser.errors.add_to_base("problems ahoy")
      Scraper.expects(:find).returns(@scraper)
      get :show, :id => @scraper.id, :dry_run => true
    end
    
    should_assign_to :scraper, :results
    should_respond_with :success
    
    should "show summary of problems" do
      assert_select "div.errorExplanation" do
        assert_select "li", "problems ahoy"
      end
    end
  end
  
  context "on GET to :show with :process" do
    setup do
      @scraper = Factory(:scraper)
    end
      
    should "run test on scraper" do
      @scraper.class.any_instance.expects(:process).with(:save_results => true).returns(stub_everything)
      get :show, :id => @scraper.id, :process => true
    end
  end
  
  context "on GET to :show with successful :process" do
    setup do
      @scraper = Factory(:scraper)
      @scraper.class.any_instance.stubs(:_data).returns(stub_everything)
      @scraper.class.any_instance.stubs(:parsing_results).returns([{ :full_name => "Fred Flintstone", :uid => 1, :url => "http://www.anytown.gov.uk/members/fred" }] )
      get :show, :id => @scraper.id, :process => true
    end
  
    should_assign_to :scraper, :results
    should_respond_with :success
    should_change "Member.count", :by => 1
    
    should "show summary of successful results" do
      assert_select "#results" do
        assert_select "div.member" do
          assert_select "h4", /Fred Flintstone/
        end
      end
    end
  
    should "not show summary of problems" do
      assert_select "div.errorExplanation", false
    end
  end
  
  context "on GET to :show with unsuccesful :process due to failed validation" do
    setup do
      @scraper = Factory(:scraper)
      @scraper.class.any_instance.stubs(:_data).returns(stub_everything)
      @scraper.class.any_instance.stubs(:parsing_results).returns([{ :full_name => "Fred Flintstone", :uid => 1, :url => "http://www.anytown.gov.uk/members/fred" },
                                                            { :full_name => "Bob Nourl"}] )
      get :show, :id => @scraper.id, :process => true
    end
    
    should_assign_to :scraper, :results
    should_change "Member.count", :by => 1 # => Not two
    should_respond_with :success
    should "show summary of problems" do
      assert_select "div.member div.errorExplanation" do
        assert_select "li", "Url can't be blank"
      end
    end
    should "highlight member with error" do
      assert_select "div.member", :count => 2 do
        assert_select "div.error", :count => 1 do # only one of which hs error class
          assert_select "div.member div.errorExplanation" #...and that has error explanation in it
        end
     end
   end
  end

  # new test
  context "on GET to :new with no scraper type given" do
    should "raise exception" do
      assert_raise(ArgumentError) { get :new }
    end
  end
  
  context "on GET to :new with bad scraper type" do
    should "raise exception" do
      assert_raise(ArgumentError) { get :new, :type  => "Member" }
    end
  end
  
  context "on GET to :new" do
    setup do
      @council = Factory(:council)
      get :new, :type  => "InfoScraper"
    end
  
    should_assign_to :scraper
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
    should_render_a_form
    
    should "create given type of scraper" do
      assert_kind_of InfoScraper, assigns(:scraper)
    end
    
    should "show select box for councils" do
      assert_select "select[name=?]", "scraper[council_id]"
    end
    
    should "show nested form for parser" do
      assert_select "textarea#scraper_parser_attributes_item_parser"
      assert_select "input#scraper_parser_attributes_attribute_parser_object__attrib_name"
      assert_select "input#scraper_parser_attributes_attribute_parser_object__parsing_code"
    end
  end
  
  # create tests
  context "on POST to :create" do
    setup do
      @council = Factory(:council)
      @scraper_params = { :council_id => @council.id, 
                          :result_model => "Committee", 
                          :url => "http://anytown.com/committees", 
                          :parser_attributes => { :title => "new parser", 
                                                  :item_parser => "some code",
                                                  :attribute_parser_object => [{:attrib_name => "foo", :parsing_code => "bar"}] }}
    end
    
    context "with no scraper type given" do
      should "raise exception" do
        assert_raise(ArgumentError) { post :create, { :scraper => @scraper_params } }
      end
    end
    
    context "with bad scraper type" do
      should "raise exception" do
        assert_raise(ArgumentError) { get :create, { :type  => "Member", :scraper => @scraper_params } }
      end
    end
    context "with scraper type" do
      setup do
        post :create, { :type => "InfoScraper", :scraper => @scraper_params }
      end
      
      should_change "Scraper.count", :by => 1
      should_assign_to :scraper
      should_redirect_to( "the show page for scraper") { scraper_path(assigns(:scraper)) }
      should_set_the_flash_to "Successfully created scraper"

      should "save as given scraper type" do
        assert_kind_of InfoScraper, assigns(:scraper)
      end

      should_change "Parser.count", :by => 1
      
      should "save parser title" do
        assert_equal "new parser", assigns(:scraper).parser.title
      end
      
      should "save parser item_parser" do
        assert_equal "some code", assigns(:scraper).parser.item_parser
      end
      
      should "save parser attribute_parser" do
        assert_equal({:foo => "bar"}, assigns(:scraper).parser.attribute_parser)
      end
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
                                   :parser_attributes => { :id => @scraper.parser.id, :title => "new parsing title", :item_parser => "some code" }}}
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
