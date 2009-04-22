require 'test_helper'

class CommitteeTest < ActiveSupport::TestCase
  
  context "The Committee Class" do
    setup do
      @committee = Committee.create!(:title => "Some Committee", :url => "some.url", :uid => 44, :council_id => 1)
    end

    should_validate_presence_of :title, :url, :uid, :council_id
    should_validate_uniqueness_of :title
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
      @committee = Committee.new(:title => "Some Committee", :url => "some.url")
    end
    
  end
  
  private
  def new_committee(options={})
    Committee.new({:title => "Some Title"}.merge(options))
  end
end
