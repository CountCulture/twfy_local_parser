require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should create new member" do
    assert new_member.save
  end
  
  
  private
  def new_member(options={})
    Member.new({:first_name => "Bob", :last_name => "Williams"}.merge(options))
  end
end
