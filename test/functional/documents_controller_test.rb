require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  
  context "on GET to :show" do
    setup do
      # @doc_owner = Factory(:meeting)
      @document = Factory(:document, :document_owner => @doc_owner)
      get :show, :id => @document.id
    end
  
    should_assign_to(:document) { @document}
    should_respond_with :success
    should_render_template :show
    
    # should_assign_to(:councils) { @portal.councils }
  
    should "show document title in body" do
      
    end
    
    should "show body of document" do
      assert_select "#document_body", @document.body
    end
    
    # should "list all parsers" do
    #   assert_select "ul#parsers li" do
    #     assert_select "a", @parser.title
    #   end
    # end
    
  end  
end
