require 'test_helper'

class CommitteeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should create new committee" do
    assert new_committee.save
  end
  
  private
  def new_committee(options={})
    Committee.new({:title => "Some Title"}.merge(options))
  end
end
