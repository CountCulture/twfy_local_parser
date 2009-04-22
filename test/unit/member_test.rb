require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  should_validate_presence_of :first_name, :last_name, :url
  should_belong_to :council
  should_have_many :memberships
  should_have_many :committees, :through => :memberships
  should_have_named_scope :current, :conditions => "date_left IS NULL"
  
  context "The Member class" do
    setup do
      @existing_member = Factory.create(:member)
      @params = {:full_name => "Fred Wilson", :uid => 2, :council_id => 2, :party => "Independent", :url => "http:/some.url"} # uid and council_id can be anything as we stub finding of existing member
    end
    
    should_validate_uniqueness_of :uid, :scoped_to => :council_id
    should_validate_presence_of :uid
                
  end
  
  context "A Member instance" do
    setup do
      NameParser.stubs(:parse).returns(:first_name => "Fred", :last_name => "Scuttle", :title => "Prof", :qualifications => "PhD")
      @member = new_member(:full_name => "Fred Scuttle")
    end
    
    should "return full name" do
      assert_equal "Fred Scuttle", @member.full_name
    end

    should "should extract first name from full name" do
      assert_equal "Fred", @member.first_name
    end
    
    should "extract last name from full name" do
      assert_equal "Scuttle", @member.last_name
    end
    
    should "extract title from full name" do
      assert_equal "Prof", @member.title
    end
    
    should "extract qualifications from full name" do
      assert_equal "PhD", @member.qualifications
    end
    
    should "be ex_member if has left office" do
      assert new_member(:date_left => 5.months.ago).ex_member?
    end
    
    should "not be ex_member if has not left office" do
      assert !new_member.ex_member?
    end
        
    should "update details using MemberScraper" do
      # MemberScraper.any_instance.expects(:update).with(@old_member)
      # @old_member.update
    end
    
    should "update member details with info from MemberScraper" do
      # MemberScraper.any_instance.stubs(:update).returns(:party => 'Conservative')
      # @old_member.update
      # assert_equal 'Conservative', @old_member.party
    end
  end
  
  private
  def new_member(options={})
    Member.new(options)
  end
end
