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
      # scraped_members = (1..4).collect{ |i| {:full_name => "Member #{i}", :url => "some.url/#{i}", :party => 'Independent', :member_id => i }}
      # Gla::MembersScraper.any_instance.stubs(:response).returns(scraped_members)
    end
    
    should_validate_uniqueness_of :first_name, :scoped_to => [:last_name, :council_id]
    
    should "validate uniqueness of member_id scoped to council_id" do
      dup_member = Member.create(:council_id => @existing_member.council_id, :member_id => @existing_member.member_id)
      assert_equal "has already been taken", dup_member.errors[:member_id]
    end
    
    should "allow member_id to be nil" do
      dup_member = Member.create(:council_id => @existing_member.council_id)
      assert_nil dup_member.errors[:member_id]
    end
    
    should "scrape website when updating members" do
      Gla::MembersScraper.expects(:new).returns(stub(:response => []))
      Member.update_members
    end
    
    context "when building_or_updating from params" do
      
      should "should update existing record when member found for council" do
        member = Member.build_or_update(:full_name => @existing_member.full_name, :council_id => @existing_member.council.id, :party => "Independent")
        assert !member.new_record?
        assert_equal @existing_member, member
      end
      
      should "should build new record when member not found for council" do
        member = Member.build_or_update(:full_name => "Fred Wilson", :council_id => @existing_member.council.id)
        assert member.new_record?
      end
      
      should "should update attributes for existing member" do
        member = Member.build_or_update(:full_name => @existing_member.full_name, :council_id => @existing_member.council.id, :party => "Independent")
        assert_equal "Independent", member.party
      end
      
      should "should build with attributes for new member" do
        member =  Member.build_or_update(:full_name => "Fred Wilson", :council_id => @existing_member.council.id, :party => "Independent")
        assert_equal "Fred Wilson", member.full_name
        assert_equal @existing_member.council, member.council
        assert_equal "Independent", member.party
      end
    end
    
    context "when creating_or_update_and_saving from params" do
      
      context "with existing record" do
        setup do
          @coru_exist_member = Member.create_or_update_and_save(:full_name => @existing_member.full_name, :council_id => @existing_member.council.id, :party => "Independent")
        end
        
        should_not_change "Member.count"
        should_change "@existing_member.reload.party", :to => "Independent"
        
        should "return member" do
          assert_equal @existing_member, @coru_exist_member
        end
      end
      
      context "with invalid attributes for existing record" do

        should "raise Exception" do
          assert_raise(ActiveRecord::RecordInvalid) { Member.create_or_update_and_save(:full_name => @existing_member.full_name, :council_id => @existing_member.council.id, :url => nil) } 
        end
      end
      
      context "with new member" do
        setup do
          @coru_new_member = Member.create_or_update_and_save(:full_name => "Fred Wilson", :council_id => @existing_member.council.id, :url => "http://www.anytown.gov.uk/members/new_fred")
        end

        should_change "Member.count", :by => 1
        
        should "return member" do
          assert_kind_of Member, @coru_new_member
        end
        
        should "save member" do
          assert !@coru_new_member.new_record?
        end
      end
      
      context "with invalid new member" do

        should "raise Exception" do
          assert_raise(ActiveRecord::RecordInvalid) { Member.create_or_update_and_save(:full_name => "Fred Wilson", :council_id => @existing_member.council.id) } 
        end
      end
      
      
      # should "should update existing record when member found for council" do
      #   
      #   member = Member.create_or_update_and_save(:full_name => @existing_member.full_name, :council_id => @existing_member.council.id, :party => "Independent")
      #   assert !member.new_record?
      #   assert_equal @existing_member, member
      # end
      # 
      # should "should build new record when member not found for council" do
      #   member = Member.create_or_update_and_save(:full_name => "Fred Wilson", :council_id => @existing_member.council.id)
      #   assert member.new_record?
      # end
      # 
      # should "should update attributes for existing member" do
      #   member = Member.create_or_update_and_save(:full_name => @existing_member.full_name, :council_id => @existing_member.council.id, :party => "Independent")
      #   assert_equal "Independent", member.party
      # end
      # 
      # should "should build with attributes for new member" do
      #   member =  Member.create_or_update_and_save(:full_name => "Fred Wilson", :council_id => @existing_member.council.id, :party => "Independent")
      #   assert_equal "Fred Wilson", member.full_name
      #   assert_equal @existing_member.council, member.council
      #   assert_equal "Independent", member.party
      # end
      
    end
    
    # should "save new members when updating members" do
    #   old_count = Member.count
    #   Member.update_members
    #   assert_equal old_count+3, Member.count
    # end
    # 
    # should "update member details when updating members" do 
    #   Member.update_members
    #   assert_equal 'Independent', @old_member.party
    # end
    # 
    # should "mark not found members as left when updating members" do
    #   Member.update_members
    #   assert members(:current_member).ex_member?
    # end
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
