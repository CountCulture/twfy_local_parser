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
        
    context "when finding existing member from params" do

      should "should return member which has given uid and council" do
        assert_equal @existing_member, Member.find_existing(:uid => @existing_member.uid, :council_id => @existing_member.council_id)
      end
      
      should "should return nil when no record with given uid and council" do
        assert_nil Member.find_existing(:uid => @existing_member.uid, :council_id => 42)
      end
    end
    
    context "when building_or_updating from params" do
      
      should "should update existing record when member found for council" do
        Member.stubs(:find_existing).returns(@existing_member)
        member = Member.build_or_update(@params)
        assert !member.new_record?
        assert_equal @existing_member, member
      end
      
      should "overwrite only attributes passed in params" do
        Member.stubs(:find_existing).returns(@existing_member)
        member = Member.build_or_update(@params.except(:full_name))
        assert_equal "Bob Wilson", member.full_name
      end
      
      should "should build new record when member not found for council" do
        Member.stubs(:find_existing) # => returns nil
        member = Member.build_or_update(@params)
        assert member.new_record?
      end
      
      should "should update attributes for existing member" do
        Member.stubs(:find_existing).returns(@existing_member)
        member = Member.build_or_update(@params)
        assert_equal "Independent", member.party
      end
      
      should "should build with attributes for new member" do
        Member.stubs(:find_existing) # => returns nil
        member =  Member.build_or_update(@params)
        assert_equal "Fred Wilson", member.full_name
        assert_equal 2, member.council_id
        assert_equal "Independent", member.party
      end
    end
    
    context "when creating_or_update_and_saving from params" do
      
      context "with existing record" do
        setup do
          Member.expects(:find_existing).returns(@existing_member)
          @coru_exist_member = Member.create_or_update_and_save(@params) # uid and council_id can be anything as we stub finding of existing memeber
        end
        
        should_not_change "Member.count"
        should_change "@existing_member.reload.party", :to => "Independent"
        
        should "return member" do
          assert_equal @existing_member, @coru_exist_member
        end
        
        should "overwrite only attributes passed in params" do
          assert_equal "Fred Wilson", @coru_exist_member.full_name
        end
        
        should "mark changed attributes as changed_attributes" do
          assert_equal [nil, 'Independent'], @coru_exist_member.party_change
        end
      end
      
      context "with invalid attributes for existing record" do

        should "not raise Exception" do
          assert_nothing_raised() { Member.create_or_update_and_save(:full_name => @existing_member.full_name, :council_id => @existing_member.council.id, :url => nil) } 
        end
      end
      
      context "with new member" do
        setup do
          Member.expects(:find_existing) # => returns nil
          @coru_new_member = Member.create_or_update_and_save(@params)
        end

        should_change "Member.count", :by => 1
        
        should "return member" do
          assert_kind_of Member, @coru_new_member
        end
        
        should "save member" do
          assert !@coru_new_member.new_record?
        end
        
        should "mark attributes as changed_attributes" do
          assert_equal ['council_id', 'first_name', 'last_name', 'party', 'uid', 'url'].sort, @coru_new_member.changed.sort
          assert_equal [nil, 'Independent'], @coru_new_member.party_change
        end
      end
      
      context "with invalid new member" do

        should "not raise Exception" do
          assert_nothing_raised() { Member.create_or_update_and_save(:full_name => "Fred Wilson", :council_id => @existing_member.council.id) } 
        end
      end
            
    end
    
    context "when creating_or_update_and_saving! from params" do
      
      should "call create_or_update_and_save" do
        Member.expects(:build_or_update).with(:foo => "bar").returns(Member.new(@params))
        Member.create_or_update_and_save!(:foo => "bar")
      end
      
      should "return member" do
        Member.expects(:find_existing).returns(@existing_member)
        assert_kind_of Member, Member.create_or_update_and_save!(@params)
      end
      
      should "raise exception when attributes for existing record are invalid" do
        Member.expects(:find_existing).returns(@existing_member)
        assert_raise(ActiveRecord::RecordInvalid) { Member.create_or_update_and_save!(:url => nil) }
      end
      
      should "mark attributes as changed_attributes" do
        member = Member.create_or_update_and_save!(@params)
        assert_equal ['council_id', 'first_name', 'last_name', 'party', 'uid', 'url'].sort, member.changed.sort
        assert_equal [nil, 'Independent'], member.party_change
      end

      should "raise exception when new record is invalid" do
        assert_raise(ActiveRecord::RecordInvalid) { Member.create_or_update_and_save!(:full_name => "Fred Wilson", :council_id => @existing_member.council.id) } # missing uid and url
      end
    end
    
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
    
    should "provide access to new_record_before_save instance variable" do
      member = new_member
      member.instance_variable_set(:@new_record_before_save, true)
      assert member.new_record_before_save?
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
