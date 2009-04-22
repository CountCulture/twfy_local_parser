require 'test_helper'

class MeetingTest < ActiveSupport::TestCase
  context "The Meeting Class" do
    setup do
      @committee = Committee.create!(:title => "Audit Group", :url => "some.url", :uid => 33, :council_id => 1)
      @meeting = Meeting.create!(:date_held => "6 November 2008", :committee => @committee)
    end

    should_belong_to :committee
    should_validate_presence_of :date_held
    should_validate_uniqueness_of :date_held, :scoped_to => :committee_id
  end
  

  context "A Meeting instance" do
    setup do
      @committee = Committee.create!(:title => "Audit Group", :url => "some.url", :uid => 33, :council_id => 1)
      @meeting = Meeting.create!(:date_held => "6 November 2008", :committee => @committee)
    end

    should "convert date string to date" do
      assert_equal Date.new(2008, 11, 6), @meeting.date_held
    end
    
    should "return committee name and date as title" do
      assert_equal "Audit Group, 2008-11-06", @meeting.title
    end
  end

  private
  def new_meeting(options={})
    Meeting.new({:date_held => 5.days.ago}.merge(options))
  end
end
