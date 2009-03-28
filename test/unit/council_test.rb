require 'test_helper'

class CouncilTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
  should_have_many :members
  should_have_many :committees
  
  context "The Council class" do
    setup do
      # @old_member = Member.create(:full_name => "Member 3", :url => "some.url/3", :party => 'Labour')
      # scraped_members = (1..4).collect{ |i| {:full_name => "Member #{i}", :url => "some.url/#{i}", :party => 'Independent' }}
      # Gla::MembersScraper.any_instance.stubs(:response).returns(scraped_members)
    end
  end
end
