require 'test_helper'

class CommitteesControllerTest < ActionController::TestCase
  # show test
   context "on GET to :show for first record" do
     setup do
       @committee = Factory(:committee)
       get :show, :id => @committee.id
     end

     should_assign_to :committee
     should_respond_with :success
     should_render_template :show

   end  

end
