require 'test_helper'

class PortalSystemTest < ActiveSupport::TestCase
  
  context "The PortalSystem class" do
    setup do
      @existing_portal = Factory.create(:portal_system)
    end
    
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_have_many :councils
    should_have_many :parsers
  end
  
  context "A PortalSystem instance" do
    setup do
      @existing_portal = Factory.create(:portal_system)
    end

    should "alias name as title" do
      assert_equal @existing_portal.name, @existing_portal.title
    end
  end
  
end
