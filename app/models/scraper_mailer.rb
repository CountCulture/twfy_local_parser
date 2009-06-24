class ScraperMailer < ActionMailer::Base
  

  def auto_scraping_report(report_hash)
    subject    "TWFY Local :: Auto Scraping Report :: #{report_hash[:summary]}"
    recipients 'countculture@googlemail.com'
    from       'countculture@googlemail.com'
    sent_on    Time.now
    
    body       :report => report_hash[:report]
  end

end
