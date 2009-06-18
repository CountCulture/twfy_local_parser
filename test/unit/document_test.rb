require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  
  context "The Document class" do
    setup do
      @existing_document = Factory.create(:document)
    end
    
    should_validate_presence_of :body, :url
    should_validate_uniqueness_of :url
    should_belong_to :document_owner#, :polymorphic => true
  end
  
  context "A Document instance" do
    setup do
      @document = Factory.create(:document)
    end

    # should "alias name as title" do
    #   assert_equal @existing_portal.name, @existing_portal.title
    # end
  end
end
