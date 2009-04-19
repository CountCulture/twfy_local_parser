require 'test_helper'

class ScrapersHelperTest < ActionView::TestCase

  include ScrapersHelper
  
  context "class_for_result helper method" do

    should "return empty string by default" do
      assert_equal "", class_for_result(stub_everything(:errors => []))
    end
    
    should "return new when record is new" do
      assert_equal "new", class_for_result(stub_everything(:new_record? => true, :errors => []))
    end
    
    should "return error when record has errors" do
      assert_equal "error", class_for_result(stub_everything(:errors => ["foo"]))
    end
    
    should "return changed when record has changed" do
      assert_equal "changed", class_for_result(stub_everything(:changed? => true, :errors => []))
    end
    
    should "return just new when record is new and has changed" do
      assert_equal "new", class_for_result(stub_everything(:changed? => true, :new_record? => true, :errors => []))
    end
    
    should "return multiple class when record is new and has errors" do
      assert_equal "new error", class_for_result(stub_everything(:errors => ["foo"], :new_record? => true))
    end
  end
  
  context "flash_for_result helper method" do

    should "return empty string by default" do
      assert_nil flash_for_result(stub_everything(:errors => []))
    end
    
    should "return new when record is new" do
      assert_dom_equal "<span class='new flash'>new</span>", flash_for_result(stub_everything(:new_record? => true, :errors => []))
    end
    
    should "return error when record has errors" do
      assert_dom_equal "<span class='error flash'>error</span>", flash_for_result(stub_everything(:errors => ["foo"]))
    end
    
    should "return changed when record has changed" do
      assert_dom_equal "<span class='changed flash'>changed</span>", flash_for_result(stub_everything(:changed? => true, :errors => []))
    end
    
    should "return just new when record is new and has changed" do
      assert_dom_equal "<span class='new flash'>new</span>", flash_for_result(stub_everything(:changed? => true, :new_record? => true, :errors => []))
    end
    
    should "return mutiple class when record is new and has errors" do
      assert_dom_equal "<span class='new error flash'>new error</span>", flash_for_result(stub_everything(:errors => ["foo"], :new_record? => true))
    end
  end

end