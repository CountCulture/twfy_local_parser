require 'test_helper'

class MeetingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should create new member" do
    assert new_meeting.save
  end
  
  private
  def new_meeting(options={})
    Meeting.new({:date_held => 5.days.ago}.merge(options))
  end
end
