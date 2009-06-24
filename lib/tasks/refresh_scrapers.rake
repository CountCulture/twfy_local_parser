desc "Finds stale scrapers and runs them" 
task :run_stale_scrapers => :environment do
  ScraperRunner.new(:limit         => ENV["LIMIT"], 
                    :email_results => ENV["EMAIL_RESULTS"]).refresh_stale
end
