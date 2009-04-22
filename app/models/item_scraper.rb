class ItemScraper < Scraper
  validates_presence_of :url
  
  def scraping_for
    "#{result_model}s from #{url}"
  end
    
end