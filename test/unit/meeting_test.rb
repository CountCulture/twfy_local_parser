require 'test_helper'

class MeetingTest < ActiveSupport::TestCase
  should_belong_to :committee
  should_validate_presence_of :date_held

  context "A Meeting instance" do
    setup do
     @meeting = Meeting.new(:date_held => 5.days.ago)
    end

  # should "return full name" do
  #   assert_equal "Bob Williams", @member.full_name
  # end
  end

  private
  def new_meeting(options={})
    Meeting.new({:date_held => 5.days.ago}.merge(options))
  end
end
