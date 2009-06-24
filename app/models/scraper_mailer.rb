class ScraperMailer < ActionMailer::Base
  

  def auto_scraping_report(report_body)
    subject    'TWFY Local :: Auto Scraping Report'
    recipients 'countculture@googlemail.com'
    from       'countculture@googlemail.com'
    sent_on    Time.now
    
    body       :report => report_body
  end

end
