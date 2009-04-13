require 'test_helper'

class CouncilTest < ActiveSupport::TestCase
  
  context "The Council class" do
    setup do
      @council = Factory(:council)
    end
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_have_many :members
    should_have_many :committees
    should_have_many :scrapers
  end
  
  context "A Council instance" do
    setup do
      # 
    end

    # # should "description" do
    # #   
    # # end
  end
  
end
