require 'test_helper'

class ScraperMailerTest < ActionMailer::TestCase
  context "A ScraperMailer auto_scraping_report email" do
    setup do
      @report_text = "auto_scraping_report body text"
      @report = ScraperMailer.create_auto_scraping_report(@report_text)
    end

    should "be sent from countculture" do
      assert_equal "countculture@googlemail.com", @report.from[0]
    end
    
    should "be sent to countculture" do
      assert_equal "countculture@googlemail.com", @report.to[0]
    end
    
    should "have subject" do
      assert_equal "TWFY Local :: Auto Scraping Report", @report.subject
    end
    
    should "include report text in body" do
      assert_match /#{@report_text}/, @report.body
    end
  end
  
end
