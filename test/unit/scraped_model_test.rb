require "test_helper"

class TestModel <ActiveRecord::Base
  include ScrapedModel
  set_table_name "members"
end

class ScrapedModelTest < Test::Unit::TestCase
  
  context "A class that includes ScrapedModel mixin" do
    setup do
      TestModel.delete_all # doesn't seem to delete old records !?!
      @test_model = TestModel.create!(:uid => 33, :council_id => 99)
      @params = {:uid => 2, :council_id => 2, :party => "Independent", :url => "http:/some.url"} # uid and council_id can be anything as we stub finding of existing member
    end

    context "when finding existing member from params" do

      should "should return member which has given uid and council" do
        assert_equal @test_model, TestModel.find_existing(:uid => @test_model.uid, :council_id => @test_model.council_id)
      end
      
      should "should return nil when no record with given uid and council" do
        assert_nil TestModel.find_existing(:uid => @test_model.uid, :council_id => 42)
      end
    end
    
    context "when building_or_updating from params" do
      setup do
      end
      
      should "should use existing record if it exists" do
        TestModel.expects(:find_existing).returns(@test_model)
        
        TestModel.build_or_update(@params)
      end
      
      should "return existing record if it exists" do
        TestModel.stubs(:find_existing).returns(@test_model)
        
        rekord = TestModel.build_or_update(@params)
        assert_equal @test_model, rekord
      end
      
      should "update existing record" do
        TestModel.stubs(:find_existing).returns(@test_model)
        rekord = TestModel.build_or_update(@params)
        assert_equal 2, rekord.council_id
        assert_equal "Independent", rekord.party
      end
      
      should "should build with attributes for new member when existing not found" do
        TestModel.stubs(:find_existing) # => returns nil
        TestModel.expects(:new).with(@params)
        
        TestModel.build_or_update(@params)
      end
      
      should "should return new record when existing not found" do
        TestModel.stubs(:find_existing) # => returns nil
        dummy_new_record = stub
        TestModel.stubs(:new).returns(dummy_new_record)
        
        assert_equal dummy_new_record, TestModel.build_or_update(@params)
      end
      
    end
    
    context "when creating_or_update_and_saving from params" do

      context "with existing record" do
        setup do
          @dummy_record = stub_everything
        end
        
        should "build_or_update on class" do
          TestModel.expects(:build_or_update).with(@params).returns(@dummy_record)
          TestModel.create_or_update_and_save(@params)
        end
        
        should "save_without_losing_dirty on record built or updated" do
          TestModel.stubs(:build_or_update).returns(@dummy_record)
          @dummy_record.expects(:save_without_losing_dirty)
          TestModel.create_or_update_and_save(@params)
        end
        
        should "return updated record" do
          TestModel.stubs(:build_or_update).returns(@dummy_record)
          assert_equal @dummy_record, TestModel.create_or_update_and_save(@params)
        end
        
        should "not raise exception if saving fails" do
          TestModel.stubs(:build_or_update).returns(@dummy_record)
          @dummy_record.stubs(:save_without_losing_dirty)
          assert_nothing_raised() { TestModel.create_or_update_and_save(@params) }
        end
      end
    end

    context "when creating_or_update_and_saving! from params" do
      setup do
        @dummy_record = stub_everything
        @dummy_record.stubs(:save_without_losing_dirty).returns(true)
      end
            
      should "build_or_update on class" do
        TestModel.expects(:build_or_update).with(@params).returns(@dummy_record)
        TestModel.create_or_update_and_save!(@params)
      end
      
      should "save_without_losing_dirty on record built or updated" do
        TestModel.stubs(:build_or_update).returns(@dummy_record)
        @dummy_record.expects(:save_without_losing_dirty).returns(true)
        TestModel.create_or_update_and_save!(@params)
      end
      
      should "return updated record" do
        TestModel.stubs(:build_or_update).returns(@dummy_record)
        assert_equal @dummy_record, TestModel.create_or_update_and_save!(@params)
      end
      
      should "raise exception if saving fails" do
        TestModel.stubs(:build_or_update).returns(@dummy_record)
        @dummy_record.stubs(:save_without_losing_dirty)
        assert_raise(ActiveRecord::RecordNotSaved) {  TestModel.create_or_update_and_save!(@params) }
      end
    end

  end
 
 context "An instance of a class that includes ScrapedModel mixin" do
   setup do
     @test_model = TestModel.new(:uid => 42)
   end
   
   should "provide access to new_record_before_save instance variable" do
     @test_model.instance_variable_set(:@new_record_before_save, true)
     assert @test_model.new_record_before_save?
   end
   
   should "save_without_losing_dirty" do
     assert @test_model.respond_to?(:save_without_losing_dirty)
   end
   
   context "when saving_without_losing_dirty" do
     setup do
       @test_model.save_without_losing_dirty
     end
     
     should_change "TestModel.count", :by => 1
     should "save record" do
       assert !@test_model.new_record?
     end
     
     should "keep record of new attributes" do
       assert_equal [nil, 42], @test_model.changes['uid']
     end
     
     should "return true if successfully saves" do
       @test_model.expects(:save).returns(true)
       assert @test_model.save_without_losing_dirty
     end
     
     should "return false if does not successfully save" do
       @test_model.expects(:save).returns(false)
       assert !@test_model.save_without_losing_dirty
     end
     
   end
 end
  
end