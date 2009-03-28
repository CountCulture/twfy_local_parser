#attributes: uri

class MemberScraper < ActiveRecord::Base
  belongs_to :parser
  belongs_to :council
  
  def self.update
    doc = Hpricot(_http_get(uri))
    results = parser.process(doc)
    Member.update_with(results)
    
  end
end
