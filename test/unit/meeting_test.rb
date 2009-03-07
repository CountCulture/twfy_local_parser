require 'test_helper'

class MeetingTest < ActiveSupport::TestCase
  should_belong_to :committee
  should_validate_presence_of :date_held

  context "A Meeting instance" do
    setup do
     @meeting = Meeting.new(:date_held => "6 November 2008")
    end

    should "convert date string to date" do
      assert_equal Date.new(2008, 11, 6), @meeting.date_held
    end
  end

  private
  def new_meeting(options={})
    Meeting.new({:date_held => 5.days.ago}.merge(options))
  end
end
