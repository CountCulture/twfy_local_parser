# attributes item_parser, title, attribute_parser

class Parser < ActiveRecord::Base
  ALLOWED_RESULT_CLASSES = %w(Member Committee Meeting)
  AttribObject = Struct.new(:attrib_name, :parsing_code, :to_param)
  validates_presence_of :result_model
  validates_presence_of :scraper_type
  validates_inclusion_of :result_model, :in => ALLOWED_RESULT_CLASSES, :message => "is invalid"
  has_many :scrapers
  belongs_to :portal_system
  serialize :attribute_parser
  attr_reader :results
  
  def attribute_parser_object
    return [AttribObject.new] if attribute_parser.blank?
    self.attribute_parser.collect { |k,v| AttribObject.new(k.to_s, v) }.sort{ |a,b| a.attrib_name <=> b.attrib_name }
  end
  
  def attribute_parser_object=(params)
    result_hash = {}
    params.each do |a|
      result_hash[a["attrib_name"].to_sym] = a["parsing_code"]
    end
    self.attribute_parser = result_hash
  end
  
  def process(doc)
    @raw_response = doc
    now_parsing = "items"
    parsing_code = item_parser
    object_to_be_parsed = doc
    
    items = item_parser.blank? ? doc : doc.instance_eval(item_parser)
    
    now_parsing = "attributes"
    items = [items] unless items.is_a?(Array)
    @results = items.collect do |item|
      result_hash = {}
      attribute_parser.each do |key, value|
        parsing_code = value
        object_to_be_parsed = item
        result_hash[key] = item.instance_eval(value)
      end
      result_hash
    end
    logger.debug { "*********results from processing parser = #{@results.inspect}" }
    self
  rescue Exception => e
    message = "Exception raised parsing #{now_parsing}: #{e.message}\n" +
                "Problem occurred using parsing code <code>#{parsing_code}</code> on following Hpricot object: #{object_to_be_parsed.inspect}"
    logger.debug { message }
    logger.debug { "Backtrace:\n#{e.backtrace}" }
    errors.add_to_base(message)
    self
  end
  
  def title
    "#{result_model} #{scraper_type.sub('Scraper','').downcase} parser for #{portal_system.try(:name) || 'this scraper only'}"
  end
  
end
