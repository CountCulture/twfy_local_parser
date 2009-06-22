require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  
  # show test
   context "on GET to :show" do
     setup do
       @member = Factory(:member)
       @council = @member.council
       @committee = Factory(:committee, :council => @council)
       @member.committees << @committee
     end
     context "with basic request" do
       setup do
         get :show, :id => @member.id
       end

       should_assign_to(:member) { @member }
       should_assign_to(:council) { @council }
       should_assign_to :committees
       should_respond_with :success
       should_render_template :show
       should_respond_with_content_type 'text/html'
       should "list committee memberships" do
         assert_select "#committees ul a", @committee.title
       end
       should "show member name in title" do
         assert_select "title", /#{@member.full_name}/
       end
     end
     
     context "with xml requested" do
       setup do
         get :show, :id => @member.id, :format => "xml"
       end

       should_assign_to(:member) { @member }
       should_respond_with :success
       should_render_without_layout
       should_respond_with_content_type 'application/xml'
     end

     context "with json requested" do
       setup do
         get :show, :id => @member.id, :format => "json"
       end

       should_assign_to(:member) { @member }
       should_respond_with :success
       should_render_without_layout
       should_respond_with_content_type 'application/json'
     end

   end  

end
