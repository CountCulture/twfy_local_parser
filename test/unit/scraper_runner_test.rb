require "test_helper"

class ScraperRunnerTest < ActiveSupport::TestCase
  context "A ScraperRunner instance" do
    setup do
      @runner = ScraperRunner.new(:email_results => true, :limit => 42)
    end
    
    should "set email_results reader from options" do
      assert @runner.email_results
    end
    
    should "set email_results reader to false by default" do
      assert !ScraperRunner.new.email_results
    end
    
    should "set limit reader from options" do
      assert_equal 42, @runner.limit
    end
    
    should "set limit to 5 by default" do
      assert_equal 5, ScraperRunner.new.limit
    end
    
    should "have result_output accessor" do
      @runner.result_output = "foo"
      assert_equal "foo", @runner.result_output
    end
    
    should "set result_output to be empty string by default" do
      assert_equal "", ScraperRunner.new.result_output
    end
    
    context "when refreshing stale scrapers" do
      setup do
        ActionMailer::Base.deliveries.clear
        @scraper = Factory(:scraper)
        Scraper.stubs(:find).returns([@scraper])
      end
      
      should "find stale scrapers" do
        Scraper.expects(:find).returns([])
        @runner.refresh_stale
      end
      
      should "process stale scrapers" do
        @scraper.expects(:process).returns(@scraper)
        @runner.refresh_stale
      end
      
      should "email results if email_results is true" do
        @runner.result_output = "some output"
        @runner.refresh_stale
        assert_sent_email do |email|
           email.subject =~ /Auto Scraping Report/ && email.body =~ /some output/
         end
      end
      
      should "not email results if email_results is not true" do
        ScraperRunner.new.refresh_stale
        assert_did_not_send_email
      end
    end
    
  end
  
end
