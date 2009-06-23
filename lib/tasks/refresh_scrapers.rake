desc "Finds stale scrapers and runs them" 
task :run_stale_scrapers => :environment do
  # stale_scrapers = Scraper.stale.find_all_by_type(:conditions => :result_model => result_model, :scraper_type => scraper_type)
  limit = ENV["LIMIT"] || 5
  stale_scrapers = Scraper.stale.find(:all, :limit => limit, :order => "last_scraped", :conditions => { :problematic => false })
  puts "About to run #{stale_scrapers.size} stale scrapers:\n"
  stale_scrapers.each do |scraper|
    
    puts "\n\nRunning #{scraper.title}\n==========================================="
    results = scraper.process(:save_results => true).results
    if results.blank?
      puts "No results"
      puts "\n\nScraper Errors:\n* #{scraper.errors.full_messages.join("\n* ")}"
      puts "\n\nParser Errors:\n* #{scraper.parser.errors.full_messages.join("\n* ")}"
    else
      results.each do |result|
        puts "\n*#{result.title}", "Changes: #{result.changes}"
      end
    end
  end
end
