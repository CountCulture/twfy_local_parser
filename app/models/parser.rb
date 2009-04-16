# attributes parsing_code, title

class Parser < ActiveRecord::Base
  has_many :scrapers
  validates_presence_of :title, :item_parser
  serialize :attribute_parser
  attr_reader :results
  
  def process(hpricot_doc)
    @raw_response = hpricot_doc
    items = hpricot_doc.instance_eval(item_parser)
    items = [items] unless items.is_a?(Array)
    @results = items.collect do |item|
      result_hash = {}
      attribute_parser.each do |key, value|
        result_hash[key] = item.instance_eval(value)
      end
      result_hash
    end
    self
  rescue Exception => e
    message = "Exception raised (#{e.message}) by parsing code(#{item_parser})"
    errors.add_to_base(message)
    self
  end
  
end
