#attributes: uri

class Scraper < ActiveRecord::Base
  belongs_to :parser
  belongs_to :council
  validates_presence_of :url
  
  # tries to get model this scraper is associated with
  # e.g. MemberScraper is associated with Member. Can be
  # overridden by individual scrapers
  def self.assoc_model
    Member
  end
  
  def self.update
    doc = Hpricot(_http_get(uri))
    results = parser.process(doc)
    assoc_model.update_with(results)
  end
end
