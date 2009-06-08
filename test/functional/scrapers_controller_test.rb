require 'test_helper'

class ScrapersControllerTest < ActionController::TestCase

  # index test
  context "on GET to :index without auth" do
    setup do
      Factory(:scraper)
      get :index
    end
  
    should_respond_with 401
  end
  
  context "on GET to :index" do
    setup do
      stub_authentication
      @scraper1 = Factory(:scraper)
      @portal_system = Factory(:portal_system)
      @council2 = Factory(:another_council, :portal_system => @portal_system)
      @scraper2 = Factory(:info_scraper, :council => @council2)
      get :index
    end
  
    should_assign_to :councils
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    
    should "list all councils" do
      assert_select "#councils" do
        assert_select ".council", 2 do
          assert_select "h3 a", @scraper1.council.name
        end
      end
    end
    
    should "list scrapers for each council" do
      assert_select "#council_#{@scraper1.council.id}" do
        assert_select "li a", @scraper1.title
      end
    end
    
    should "link to portal system if council has portal system" do
      assert_select "#council_#{@scraper2.council.id}" do
        assert_select "a", @portal_system.name
      end
    end
    
  end
  
  # show test
  context "on GET to :show for first record without auth" do
    setup do
      @scraper = Factory(:scraper)
      get :show, :id => @scraper.id
    end
  
    should_respond_with 401
  end

  context "on GET to :show for first record" do
    setup do
      @scraper = Factory(:scraper)
      @scraper.class.any_instance.expects(:test).never
      stub_authentication
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
      stub_authentication
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
      stub_authentication
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
      stub_authentication
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
      stub_authentication
      get :show, :id => @scraper.id, :process => true
    end
  end
  
  context "on GET to :show with successful :process" do
    setup do
      @scraper = Factory(:scraper)
      @scraper.class.any_instance.stubs(:_data).returns(stub_everything)
      @scraper.class.any_instance.stubs(:parsing_results).returns([{ :full_name => "Fred Flintstone", :uid => 1, :url => "http://www.anytown.gov.uk/members/fred" }] )
      stub_authentication
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
      stub_authentication
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
  context "on GET to :new without auth" do
    setup do
      @council = Factory(:council)
      get :new, :type  => "InfoScraper", :council_id => @council.id
    end
  
    should_respond_with 401
  end

  context "on GET to :new with no scraper type given" do
    should "raise exception" do
      stub_authentication
      assert_raise(ArgumentError) { get :new }
    end
  end
  
  context "on GET to :new with bad scraper type" do
    should "raise exception" do
      stub_authentication
      assert_raise(ArgumentError) { get :new, :type  => "Member" }
    end
  end
  
  context "on GET to :new with no given council" do
    should "raise exception" do
      stub_authentication
      assert_raise(ArgumentError) { get :new, :type  => "InfoScraper" }
    end
  end
  
  context "on GET to :new" do
    setup do
      @council = Factory(:council)
    end
  
    context "for basic scraper" do
      setup do
        stub_authentication
        get :new, :type  => "InfoScraper", :council_id => @council.id
      end
  
      should_assign_to :scraper
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
      should_render_a_form
  
      should "assign given type of scraper" do
        assert_kind_of InfoScraper, assigns(:scraper)
      end
    
      should "build parser from params" do
        assert assigns(:scraper).parser.new_record?
        assert_equal "InfoScraper", assigns(:scraper).parser.scraper_type
      end
      
      should "show nested form for parser" do
        assert_select "textarea#scraper_parser_attributes_item_parser"
        assert_select "input#scraper_parser_attributes_attribute_parser_object__attrib_name"
        assert_select "input#scraper_parser_attributes_attribute_parser_object__parsing_code"
      end
  
      should "include scraper type in hidden field" do
        assert_select "input#type[type=hidden][value=InfoScraper]"
      end
      
      should "include council in hidden field" do
        assert_select "input#scraper_council_id[type=hidden][value=#{@council.id}]"
      end
      
      should "not show select box for possible_parsers" do
        assert_select "select#scraper_parser_id", false
      end
      
      should "not show related_model select_box for info scraper" do
        assert_select "select#scraper_parser_attributes_related_model", false
      end
      
      should "not have hidden parser details form" do
        assert_select "fieldset#parser_details[style='display:none']", false
      end
      
      should "not have link to show parser form" do
        assert_select "form a", :text => /use dedicated parser/i, :count => 0
      end

      should "show hidden field with parser scraper_type" do
        assert_select "input#scraper_parser_attributes_scraper_type[type=hidden][value=InfoScraper]"
      end
      
    end
    
    context "for basic scraper with given result model" do
      setup do
        Factory(:parser, :result_model => "Committee", :scraper_type => "InfoScraper") # make sure there's at least one parser already in db with this result model
        stub_authentication
        get :new, :type  => "InfoScraper", :council_id => @council.id, :result_model => "Committee"
      end
  
      should "build parser from params" do
        assert assigns(:scraper).parser.new_record?
        assert_equal "Committee", assigns(:scraper).result_model
        assert_equal "InfoScraper", assigns(:scraper).parser.scraper_type
      end
  
      should "show result_model select box in form" do
        assert_select "select#scraper_parser_attributes_result_model" do
          assert_select "option[value='Committee'][selected='selected']"
        end
      end
    end
    
    context "for basic item_scraper" do
      setup do
        stub_authentication
        get :new, :type  => "ItemScraper", :council_id => @council.id
      end
  
      should_assign_to :scraper
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
      should_render_a_form
  
      should "assign given type of scraper" do
        assert_kind_of ItemScraper, assigns(:scraper)
        assert assigns(:scraper).new_record?
      end
      
      should "not show related_model select_box for info scraper" do
        assert_select "select#scraper_parser_attributes_related_model"
      end
    end
    
    context "when scraper council has portal system" do
      setup do
        @portal_system = Factory(:portal_system, :name => "Some Portal for Councils")
        @portal_system.parsers << @parser = Factory(:another_parser) # add a parser to portal_system...
        @council.update_attribute(:portal_system_id, @portal_system.id)# .. and associate portal_system to council
        @parser = Factory(:parser, :portal_system => @portal_system)
        stub_authentication
        get :new, :type  => "ItemScraper", :result_model => @parser.result_model, :council_id => @council.id
      end
    
      should_assign_to :scraper 
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
      should_render_a_form
      
      should "assign appropriate parser to scraper" do
        assert_equal @parser, assigns(:scraper).parser
      end
      
      should "show text box for url" do
        assert_select "input#scraper_url"
      end
  
      should "show hidden field with parser details" do
        assert_select "input#scraper_parser_id[type=hidden][value=#{@parser.id}]"
      end
      
      should "not show parser_details form" do
        assert_select "fieldset#parser_details", false
      end
      
      # should "have hidden parser details form" do
      #   assert_select "fieldset#parser_details[style='display:none']"
      # end
      # 
      # should "not use parser in parser details form" do
      #   assert_select "fieldset#parser_details input#scraper_parser_attributes_description[value='#{@parser.description}']", false
      # end
      # 
      # should "show result_model in parser details form" do
      #   assert_select "select#scraper_parser_attributes_result_model option[selected='selected'][value='#{@parser.result_model}']"
      # end
      # 
      # should "not show parser attribute_parser details in parser form" do
      #   assert_select "input#scraper_parser_attributes_attribute_parser_object__attrib_name[value='#{@parser.attribute_parser.keys.first}']", false
      # end
      # 
      # should "show hidden field with parser scraper_type" do
      #   assert_select "input#scraper_parser_attributes_scraper_type[type=hidden][value=ItemScraper]"
      # end
      
      should "show parser details" do
        assert_select "div#parser_#{@parser.id}"
      end
      
      should "have link to show parser form" do
        assert_select "form a", /use dedicated parser/i
      end
    end
    
    context "when scraper council has portal system but dedicated parser specified" do
      setup do
        @portal_system = Factory(:portal_system, :name => "Some Portal for Councils")
        @portal_system.parsers << @parser = Factory(:another_parser) # add a parser to portal_system...
        @council.update_attribute(:portal_system_id, @portal_system.id)# .. and associate portal_system to council
        @parser = Factory(:parser, :portal_system => @portal_system)
        stub_authentication
        get :new, :type  => "ItemScraper", :result_model => @parser.result_model, :council_id => @council.id, :dedicated_parser => true
      end
    
      should_assign_to :scraper 
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
      should_render_a_form
      
      should "assign appropriate parser to scraper" do
        assert_equal @parser, assigns(:scraper).parser
      end
      
      should "show text box for url" do
        assert_select "input#scraper_url"
      end
  
      should "show parser_details form" do
        assert_select "fieldset#parser_details"
      end
      
      should "show not show hidden field with parser details" do
        assert_select "input#scraper_parser_id[type=hidden][value=#{@parser.id}]", false
      end
      
      # should "have hidden parser details form" do
      #   assert_select "fieldset#parser_details[style='display:none']"
      # end
      # 
      # should "not use parser in parser details form" do
      #   assert_select "fieldset#parser_details input#scraper_parser_attributes_description[value='#{@parser.description}']", false
      # end
      # 
      # should "show result_model in parser details form" do
      #   assert_select "select#scraper_parser_attributes_result_model option[selected='selected'][value='#{@parser.result_model}']"
      # end
      # 
      # should "not show parser attribute_parser details in parser form" do
      #   assert_select "input#scraper_parser_attributes_attribute_parser_object__attrib_name[value='#{@parser.attribute_parser.keys.first}']", false
      # end
      # 
      # should "show hidden field with parser scraper_type" do
      #   assert_select "input#scraper_parser_attributes_scraper_type[type=hidden][value=ItemScraper]"
      # end
      
      # should "show parser details" do
      #   assert_select "div#parser_#{@parser.id}"
      # end
      # 
      # should "have link to show parser form" do
      #   assert_select "form a", /use dedicated parser/i
      # end
    end
    
    context "when scraper council has portal system but parser does not exist" do
      setup do
        @portal_system = Factory(:portal_system, :name => "Some Portal for Councils")
        @portal_system.parsers << @parser = Factory(:another_parser) # add a parser to portal_system...
        @council.update_attribute(:portal_system_id, @portal_system.id)# .. and associate portal_system to council
        @parser = Factory(:parser, :portal_system => @portal_system)
        stub_authentication
        get :new, :type  => "ItemScraper", :result_model => "Meeting", :council_id => @council.id
      end
    
      should_assign_to :scraper 
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
      should_render_a_form
      
      should "assign appropriate fresh parser to scraper" do
        assert assigns(:scraper).parser.new_record?
      end
      
      should "show text box for url" do
        assert_select "input#scraper_url"
      end
  
      should "show parser details form" do
        assert_select "fieldset#parser_details"
      end
      
      should "show link to add new parser for portal_system" do
        assert_select "form p.alert", /no parser/i do
          assert_select "a", /add new/i
        end
      end
    end
  end
  
  # create tests

  context "on POST to :create" do
    setup do
      @council = Factory(:council)
      @portal_system = Factory(:portal_system, :name => "Another portal system")
      @existing_parser = Factory(:parser, :portal_system => @portal_system, :description => "existing parser")
      
      @scraper_params = { :council_id => @council.id, 
                          :url => "http://anytown.com/committees", 
                          :parser_attributes => { :description => "new parser", 
                                                  :result_model => "Committee", 
                                                  :scraper_type => "InfoScraper", 
                                                  :item_parser => "some code",
                                                  :attribute_parser_object => [{:attrib_name => "foo", :parsing_code => "bar"}] }}
      @exist_scraper_params = { :council_id => @council.id, 
                                :url => "http://anytown.com/committees", 
                                :parser_id => @existing_parser.id }
    end
    
    context "without auth" do
      setup do
        post :create, { :type => "InfoScraper", :scraper => @scraper_params }
      end

      should_respond_with 401
    end
    
    context "with no scraper type given" do
      should "raise exception" do
        stub_authentication
        assert_raise(ArgumentError) { post :create, { :scraper => @scraper_params } }
      end
    end
    
    context "with bad scraper type" do
      should "raise exception" do
        stub_authentication
        assert_raise(ArgumentError) { get :create, { :type  => "Member", :scraper => @scraper_params } }
      end
    end
    
    context "with scraper type" do
      
      context "and new parser" do
        setup do
          stub_authentication
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
      
        should "save parser description" do
          assert_equal "new parser", assigns(:scraper).parser.description
        end
      
        should "save parser item_parser" do
          assert_equal "some code", assigns(:scraper).parser.item_parser
        end
      
        should "save parser attribute_parser" do
          assert_equal({:foo => "bar"}, assigns(:scraper).parser.attribute_parser)
        end
      end
      
      context "and existing parser" do
        setup do
          stub_authentication
          post :create, { :type => "InfoScraper", :scraper => @exist_scraper_params }
        end
      
        should_change "Scraper.count", :by => 1
        should_assign_to :scraper
        should_redirect_to( "the show page for scraper") { scraper_path(assigns(:scraper)) }
        should_set_the_flash_to "Successfully created scraper"
      
        should "save as given scraper type" do
          assert_kind_of InfoScraper, assigns(:scraper)
        end
      
        should_not_change "Parser.count"
      
        should "associate existing parser to scraper " do
          assert_equal @existing_parser, assigns(:scraper).parser
        end
      
      end
      
      context "and new parser and existing parser details both given" do
        setup do
          stub_authentication
          post :create, { :type => "InfoScraper", :scraper => @scraper_params.merge(:parser_id => @existing_parser.id ) }
        end
      
        should_change "Scraper.count", :by => 1
        should_change "Parser.count", :by => 1
        should_assign_to :scraper
        should_redirect_to( "the show page for scraper") { scraper_path(assigns(:scraper)) }
        should_set_the_flash_to "Successfully created scraper"
      
        should "save parser description from new details" do
          assert_equal "new parser", assigns(:scraper).parser.description
        end
      end
            
    end
    
  end
  
  # edit tests
  context "on get to :edit a scraper without auth" do
    setup do
      @scraper = Factory(:scraper)
      get :edit, :id => @scraper.id
    end
  
    should_respond_with 401
  end

  context "on get to :edit a scraper" do
    setup do
      @scraper = Factory(:scraper)
      stub_authentication
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
  context "on PUT to :update without auth" do
    setup do
      @scraper = Factory(:scraper)
      put :update, { :id => @scraper.id, 
                     :scraper => { :council_id => @scraper.council_id, 
                                   :result_model => "Committee", 
                                   :url => "http://anytown.com/new_committees", 
                                   :parser_attributes => { :id => @scraper.parser.id, :description => "new parsing description", :item_parser => "some code" }}}
    end
  
    should_respond_with 401
  end
  
  context "on PUT to :update" do
    setup do
      @scraper = Factory(:scraper)
      stub_authentication
      put :update, { :id => @scraper.id, 
                     :scraper => { :council_id => @scraper.council_id, 
                                   :result_model => "Committee", 
                                   :url => "http://anytown.com/new_committees", 
                                   :parser_attributes => { :id => @scraper.parser.id, :description => "new parsing description", :item_parser => "some code" }}}
    end
  
    should_assign_to :scraper
    should_redirect_to( "the show page for scraper") { scraper_path(@scraper) }
    should_set_the_flash_to "Successfully updated scraper"
    
    should "update scraper" do
      assert_equal "http://anytown.com/new_committees", @scraper.reload.url
    end
    
    should "update scraper parser" do
      assert_equal "new parsing description", @scraper.parser.reload.description
    end
  end
  
  # delete tests
  context "on delete to :destroy a scraper without auth" do
    setup do
      @scraper = Factory(:scraper)
      delete :destroy, :id => @scraper.id
    end
  
    should_respond_with 401
  end
  
  context "on delete to :destroy a scraper" do
    
    setup do
      @scraper = Factory(:scraper)
      stub_authentication
      delete :destroy, :id => @scraper.id
    end
    
    should "destroy scraper" do
      assert_nil Scraper.find_by_id(@scraper.id)
    end
    should_redirect_to ( "the scrapers page") { scrapers_url(:anchor => "council_#{@scraper.council_id}") }
    should_set_the_flash_to "Successfully destroyed scraper"
  end
  
end
