require 'test_helper'

class CommitteeTest < ActiveSupport::TestCase
  
  context "The Committee Class" do
    setup do
      @committee = Committee.create!(:title => "Some Committee", :url => "some.url")
    end

    should_validate_presence_of :title, :url
    should_validate_uniqueness_of :title
    should_have_many :meetings
    should_have_many :memberships
    should_have_many :members, :through => :memberships
  end
    
  context "A Committee instance" do
    setup do
      @committee = Committee.new(:title => "Some Committee", :url => "some.url")
    end
    
    # should "return full name" do
    #   assert_equal "Bob Williams", @member.full_name
    # end
  end
  
  private
  def new_committee(options={})
    Committee.new({:title => "Some Title"}.merge(options))
  end
end
