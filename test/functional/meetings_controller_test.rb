require 'test_helper'

class MeetingsControllerTest < ActionController::TestCase
  
  def setup
    @committee = Factory(:committee)
    @council = @committee.council
    @member = Factory(:member, :council => @council)
    @meeting = Factory(:meeting, :council => @council, :committee => @committee)
    @another_meeting = Factory(:meeting, :date_held => 3.days.from_now.to_date, :council => @council, :committee => @committee, :uid => @meeting.uid+1)
    @committee.members << @member
  end
  
  # index tests
  context "on GET to :index for council" do
    
    context "with basic request" do
      setup do
        get :index, :council_id => @council.id
      end
  
      should_assign_to(:council) { @council } 
      should_assign_to(:meetings) { [@another_meeting, @meeting] } # most recent first
      should_respond_with :success
      should_render_template :index
      should_respond_with_content_type 'text/html'
      
      should "list meetings" do
        assert_select "#meetings ul a", @meeting.title
      end
      
      should "have title" do
        assert_select "title", /Committee meetings for #{@council.title}/
      end
    end
        
    context "with xml requested" do
      setup do
        get :index, :council_id => @council.id, :format => "xml"
      end
  
      should_assign_to(:council) { @council } 
      should_assign_to(:meetings) { [@another_meeting, @meeting]} # most recent first
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/xml'
    end
    
    context "with json requested" do
      setup do
        get :index, :council_id => @council.id, :format => "json"
      end
  
      should_assign_to(:council) { @council } 
      should_assign_to(:meetings) { [@another_meeting, @meeting]} # most recent first
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/json'
    end
  end

  # show tests
  context "on GET to :show" do
    
    context "with basic request" do
      setup do
        get :show, :id => @meeting.id
      end

      should_assign_to :meeting, :committee
      should_respond_with :success
      should_render_template :show
     
      should "show committee in title" do
        assert_select "title", /#{@committee.title}/
      end
      
      should "show meeting date in title" do
        assert_select "title", /#{@meeting.date_held.to_date}/
      end
      
      should "list members" do
        assert_select "#members ul a", @member.title
      end
    
      should "list other meetings" do
        assert_select "#meetings ul a", @another_meeting.title
        assert_select "#meetings ul a", :text => @meeting.title, :count => 0
      end
    end
    
    context "when meeting has minutes" do
      setup do
        @document = Factory(:document, :document_owner => @meeting)
        get :show, :id => @meeting.id
        # p @meeting.minutes
      end

      should "show link to minutes" do
        assert_select "a", /minutes/
      end
    end
    
    context "with xml request" do
      setup do
        get :show, :id => @meeting.id, :format => "xml"
      end
    
      should_assign_to :meeting
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/xml'
      
    end
    
    context "with json request" do
      setup do
        get :show, :id => @meeting.id, :format => "json"
      end
    
      should_assign_to :meeting
      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type 'application/json'
      
    end
    
  end  
end
