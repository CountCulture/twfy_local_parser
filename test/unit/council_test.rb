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
    should_have_many :meetings
    should_belong_to :portal_system
    should_have_db_column :notes
    should_have_db_column :wikipedia_url
    should_have_db_column :ons_url
    should_have_db_column :egr_id
    
    should "return councils with members as parsed" do
      @another_council = Factory(:another_council)
      @member = Factory(:member, :council => @another_council)
      @another_member = Factory(:old_member, :council => @another_council) # add two members to @another council, @council has none
      assert_equal [@another_council], Council.parsed
    end
  end
  
  context "A Council instance" do
    setup do
      @council = Factory(:council)
    end

    should "alias name as title" do
      assert_equal @council.name, @council.title
    end
    
    should "return url as base_url if base_url is not set" do
      assert_equal @council.url, @council.base_url
    end
    
    should "return base_url as base_url if base_url is set" do
      council = Factory(:another_council, :base_url => "another.url")
      assert_equal "another.url", council.base_url
    end
    
  end
  
end
