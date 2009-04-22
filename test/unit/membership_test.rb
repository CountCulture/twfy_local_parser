require 'test_helper'

class MembershipTest < ActiveSupport::TestCase

  context "The Membership Class" do
    setup do
      # @membership = Membership.create!(:title => "Some Committee", :url => "some.url", :uid => 44, :council_id => 1)
    end

    should_validate_presence_of :member_id, :committee_id
    should_belong_to :committee
    should_belong_to :member
    
  end
end
