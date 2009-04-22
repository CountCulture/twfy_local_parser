require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  
  # show test
   context "on GET to :show for first record" do
     setup do
       @member = Factory(:member)
       get :show, :id => @member.id
     end

     should_assign_to :member
     should_assign_to :committees
     should_respond_with :success
     should_render_template :show

   end  

end
