require 'test_helper'

class MeetingsControllerTest < ActionController::TestCase
  context "on GET to :show" do
    
    setup do
      @committee = Factory(:committee)
      @member = Factory(:member, :council => @committee.council)
      @meeting = Factory(:meeting, :council => @committee.council, :committee => @committee)
      @another_meeting = Factory(:meeting, :date_held => 3.days.from_now.to_date, :council => @committee.council, :committee => @committee, :uid => @meeting.uid+1)
      @committee.members << @member
    end

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
