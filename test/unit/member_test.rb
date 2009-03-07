require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  
  context "A Member instance" do
    setup do
      @member = Member.new(:first_name => "Bob", :last_name => "Williams")
    end
    
    should "return full name" do
      assert_equal "Bob Williams", @member.full_name
    end

    should "should extract first name from full name" do
      assert_equal "Fred", new_member(:full_name => "Fred Scuttle").first_name
    end
    
    should "extract last name from full name" do
      assert_equal "Scuttle", new_member(:full_name => "Fred Scuttle").last_name
    end
  end
  
  private
  def new_member(options={})
    Member.new(options)
  end
end
