require 'test_helper'

class CommitteeTest < ActiveSupport::TestCase
  
  context "The Committee Class" do
    setup do
      @committee = Committee.create!(:title => "Some Committee", :url => "some.url", :uid => 44, :council_id => 1)
    end

    should_validate_presence_of :title, :url, :uid, :council_id
    should_validate_uniqueness_of :title, :scoped_to => :council_id
    should_have_many :meetings
    should_have_many :memberships
    should_have_many :members, :through => :memberships
    should_belong_to :council
    
    should "include ScraperModel mixin" do
      assert Committee.respond_to?(:find_existing)
    end
    
  end
    
  context "A Committee instance" do
    setup do
      @council, @another_council = Factory(:council), Factory(:another_council)
      @committee = Committee.new(:title => "Some Committee", :url => "some.url", :council_id => @council.id)
    end
    
    context "with members" do
      # this part is really just testing inclusion of uid_association extension in members association
      setup do
        @member = Factory(:member, :council => @council)
        @old_member = Factory(:old_member, :council => @council)
        @another_council_member = Factory(:member, :council => @another_council, :uid => 999)
        @committee.members << @old_member
      end

      should "return member uids" do
        assert_equal [@old_member.uid], @committee.members_uids
      end
      
      should "replace existing members with ones with given uids" do
        @committee.members_uids = [@member.uid]
        assert_equal [@member], @committee.members
      end
      
      should "not add members that don't exist for council" do
        @committee.members_uids = [@another_council_member.uid]
        assert_equal [], @committee.members
      end
      
    end
    
  end
  
  private
  def new_committee(options={})
    Committee.new({:title => "Some Title"}.merge(options))
  end
end
