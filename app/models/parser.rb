# attributes parsing_code, title

class Parser < ActiveRecord::Base
  has_many :scrapers
  validates_presence_of :title, :parsing_code
  
  def process(hpricot_doc)
    @response = hpricot_doc
    self.instance_eval(parsing_code)
  end
end
