require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  should_validate_presence_of :first_name, :last_name, :url
  should_validate_uniqueness_of :first_name, :scoped_to => :last_name
  should_have_many :memberships
  should_have_many :committees, :through => :memberships
  
  context "The Member class" do
    setup do
      @old_member = Member.create(:full_name => "Member 3", :url => "some.url/3")
      scraped_members = (1..4).collect{ |i| {:full_name => "Member #{i}", :url => "some.url/#{i}" }}
      Gla::MembersScraper.any_instance.stubs(:response).returns(scraped_members)
    end

    should "scrape wbsite when updating members" do
      Gla::MembersScraper.expects(:new).returns(stub(:response => []))
      Member.update_members
    end
    
    should "save new members when updating members" do
      old_count = Member.count
      Member.update_members
      assert_equal old_count+3, Member.count
    end
    
    should "mark members not found when updating members as left" do
      
    end
  end
  
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
    
    should "be ex_member if has left office" do
      assert new_member(:date_left => 5.months.ago).ex_member?
    end
    
    should "not be ex_member if has not left office" do
      assert !new_member.ex_member?
    end
  end
  
  private
  def new_member(options={})
    Member.new(options)
  end
end
