class ScraperRunner
  attr_accessor :result_output
  attr_reader :email_results, :limit
  def initialize(args={})
    @email_results = args[:email_results]
    @limit         = args[:limit] || 5
    @result_output = ""
  end
  
  def refresh_stale
    stale_scrapers = Scraper.unproblematic.stale.find(:all, :limit => limit)
    output_result "About to run #{stale_scrapers.size} stale scrapers:\n"
    stale_scrapers.each do |scraper|

      output_result "\n\nRunning #{scraper.title}\n==========================================="
      results = scraper.process(:save_results => true).results
      if results.blank?
        output_result "No results"
        output_result "\n\nScraper Errors:\n* #{scraper.errors.full_messages.join("\n* ")}"
        output_result "\n\nParser Errors:\n* #{scraper.parser.errors.full_messages.join("\n* ")}"
      else
        results.each do |result|
          output_result "\n*#{result.title}\nChanges: #{result.changes}"
        end
      end
    end
    ScraperMailer.deliver_auto_scraping_report!(result_output) if email_results
  end
  
  protected
  # outputs to screen or adds to result string
  def output_result(text)
    email_results ? (result_output << text) : RAILS_ENV!="test"&&puts(text)
  end
end
