require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  should_validate_presence_of :last_name, :url, :council_id
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
    should "include ScraperModel mixin" do
      assert Member.respond_to?(:find_existing)
    end
                
  end
  
  context "A Member instance" do
    setup do
      NameParser.stubs(:parse).returns(:first_name => "Fred", :last_name => "Scuttle", :name_title => "Prof", :qualifications => "PhD")
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
    
    should "extract name_title from full name" do
      assert_equal "Prof", @member.name_title
    end
    
    should "extract qualifications from full name" do
      assert_equal "PhD", @member.qualifications
    end
    
    should "alias full_name as title" do
      assert_equal @member.full_name, @member.title
    end
    
    should "be ex_member if has left office" do
      assert new_member(:date_left => 5.months.ago).ex_member?
    end
    
    should "not be ex_member if has not left office" do
      assert !new_member.ex_member?
    end
    
    should "store party attribute" do
      assert_equal "Conservative", new_member(:party => "Conservative").party
    end
    
    should "discard 'Party' from given party name" do
      assert_equal "Conservative", new_member(:party => "Conservative Party").party
      assert_equal "Conservative", new_member(:party => "Conservative party").party
    end
    
    should "strip extraneous spaces from given party name" do
       assert_equal "Conservative", new_member(:party => "  Conservative ").party
     end
     
    should "strip extraneous spaces and 'Party' from given party name" do
      assert_equal "Liberal Democrat", new_member(:party => "  Liberal Democrat Party ").party
    end

    context "with committees" do
      # this part is really just testing inclusion of uid_association extension in committees association
      setup do
        @member = Factory(:member)
        @council = @member.council
        @another_council = Factory(:another_council)
        @old_committee = Factory(:committee, :council => @council)
        @new_committee = Factory(:committee, :council => @council, :uid => @old_committee.uid+1, :title => "new committee")
        @another_council_committee = Factory(:committee, :council => @another_council, :uid => 999, :title => "another council committee")
        @member.committees << @old_committee
      end

      should "return committee uids" do
        assert_equal [@old_committee.uid], @member.committee_uids
      end
      
      should "replace existing committees with ones with given uids" do
        @member.committee_uids = [@new_committee.uid]
        assert_equal [@new_committee], @member.committees
      end
      
      should "not add committees with that don't exist for council" do
        @member.committee_uids = [@another_council_committee.uid]
        assert_equal [], @member.committees
      end
      
    end
  end
  
  
  private
  def new_member(options={})
    Member.new(options)
  end
end
