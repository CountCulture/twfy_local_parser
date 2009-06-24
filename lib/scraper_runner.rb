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
    error_total = 0
    output_result "About to run #{stale_scrapers.size} stale scrapers:\n"
    stale_scrapers.each do |scraper|

      output_result "\n\nRunning #{scraper.title}\n==========================================="
      results = scraper.process(:save_results => true).results
      if results.blank?
        output_result "No results"
        output_result "\n\nScraper Errors:\n* #{scraper.errors.full_messages.join("\n* ")}"
        output_result "\n\nParser Errors:\n* #{scraper.parser.errors.full_messages.join("\n* ")}"
        error_total +=1
      else
        results.each do |result|
          output_result "\n*#{result.title}\nChanges: #{result.changes}"
        end
      end
    end
    @summary = "#{stale_scrapers.size} scrapers processed, " + (error_total > 0 ? "#{error_total} problem(s)" : "No problems")
    email_results ? ScraperMailer.deliver_auto_scraping_report!(:report => result_output, :summary => @summary) :
                    output_result("*****"*10 + "\n" + @summary)
  end
  
  protected
  # outputs to screen or adds to result string
  def output_result(text)
    email_results ? (result_output << text) : RAILS_ENV!="test"&&puts(text)
  end
end
