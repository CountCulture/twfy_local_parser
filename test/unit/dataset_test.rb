require 'test_helper'

class DatasetTest < ActiveSupport::TestCase
  
  context "The Dataset class" do

    should_have_db_columns :title, :source, :key, :query
    should_validate_presence_of :title, :key, :query

    should "have base_url" do
      assert_match /spreadsheets.google/, Dataset::BASE_URL
    end
  end
  
  context "A Dataset instance" do
    setup do
      @dataset = Factory.create(:dataset, :query => "select A,B,C,D,E,F,G")
      @council = Factory(:council)
    end

    context "when getting data for council" do
      setup do
        @csv_response = "\"LOCAL AUTHORITY\",\"Authority Type\"\n\"Bristol City \",\"UA\""
        @dataset.stubs(:query_url).returns("some_url")
        @dataset.stubs(:_http_get).returns(@csv_response)
      end

      should "build url using council" do
        @dataset.expects(:query_url).with(@council)
        @dataset.data_for(@council)
      end
      
      should "get data from url" do
        @dataset.expects(:_http_get).with("some_url").returns(@csv_response)
        @dataset.data_for(@council)
      end
      
      should "parse csv data into ruby array" do
        parsed_response = [["LOCAL AUTHORITY", "Bristol City "], ["Authority Type", "UA"]]
        assert_equal parsed_response, @dataset.data_for(@council)
      end
    end
    
    should "build query_url from query, key when no council given" do
      @council.stubs(:short_name).returns("Foo bar")
      assert_equal Dataset::BASE_URL+'&tq=select+A%2CB%2CC%2CD%2CE%2CF%2CG&key=abc123', @dataset.query_url
    end
    
    should "build query_url from query, key and council short title" do
      @council.stubs(:short_name).returns("Foo bar")
      assert_equal Dataset::BASE_URL+'&tq=select+A%2CB%2CC%2CD%2CE%2CF%2CG+where+A+contains+%27Foo+bar%27&key=abc123', @dataset.query_url(@council)
    end
    
  end
end
