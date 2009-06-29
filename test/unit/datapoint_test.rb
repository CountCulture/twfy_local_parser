require 'test_helper'

class DatapointTest < ActiveSupport::TestCase

  context "The Datapoint class" do

    should_have_db_columns :data, :data_summary
    should_validate_presence_of :data
    
    should_belong_to :council
    should_belong_to :dataset
  end
  
  context "A Dataset instance" do
    setup do
      @datapoint = Factory.create(:datapoint, :data => [["foo"],["bar"]])
    end

    should "serialize data" do
      assert_equal [["foo"],["bar"]], @datapoint.reload.data
    end
  end
  
end
