require 'test_helper'

class CouncilsControllerTest < ActionController::TestCase

  def setup
    @member = Factory(:member)
    @council = @member.council
    @old_member = Factory(:old_member, :council => @council)
    @another_council = Factory(:another_council)
  end
  
  # show test
   context "on GET to :index" do
     setup do
       get :index
     end

     should_assign_to(:councils) { Council.find(:all)}
     should_respond_with :success
     should_render_template :index
   end  

  # show test
   context "on GET to :show for first record" do
     setup do
       get :show, :id => @council.id
     end

     should_assign_to(:council) { @council}
     should_respond_with :success
     should_render_template :show
     should_assign_to(:members) { @council.members.current }
     
     should "list all members" do
       assert_select "ul#members li", @council.members.current.size
     end
   end  

end
