# attributes parsing_code, title

class Parser < ActiveRecord::Base
  has_many :scrapers
  validates_presence_of :title, :parsing_code
  
  def process(hpricot_doc)
    @raw_response = hpricot_doc
    @results = self.instance_eval(parsing_code)
    self
  rescue Exception => e
    message = "Exception raised (#{e.message}) by parsing code(#{parsing_code})"
    errors.add_to_base(message)
    self
  end
  
end
