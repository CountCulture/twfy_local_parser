# attributes item_parser, title, attribute_parser

class Parser < ActiveRecord::Base
  ALLOWED_RESULT_CLASSES = %w(Member Committee Meeting)
  AttribObject = Struct.new(:attrib_name, :parsing_code, :to_param)
  validates_presence_of :result_model
  validates_presence_of :scraper_type
  validates_inclusion_of :result_model, :in => ALLOWED_RESULT_CLASSES, :message => "is invalid"
  validates_inclusion_of :scraper_type, :in => Scraper::SCRAPER_TYPES, :message => "is invalid"
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
  
  def process(doc, scraper=nil)
    @raw_response = doc
    @current_scraper = scraper
    @results = nil # wipe previous results if they exist (same parser instance may be called more than once by scraper)
    now_parsing = "items"
    parsing_code = item_parser
    object_to_be_parsed = doc
    
    items = item_parser.blank? ? doc : eval_parsing_code(item_parser, doc)
    now_parsing = "attributes"
    items = [items] unless items.is_a?(Array)
    @results = items.compact.collect do |item| # remove nil items
      result_hash = {}
      attribute_parser.each do |key, value|
        parsing_code = value
        object_to_be_parsed = item
        result_hash[key] = eval_parsing_code(value, item)
      end
      result_hash
    end
    logger.debug { "*********results from processing parser = #{@results.inspect}" }
    self
  rescue Exception => e
    message = "Exception raised parsing #{now_parsing}: #{e.message}\n\n" +
                "Problem occurred using parsing code:\n#{parsing_code}\n\n on following Hpricot object:\n#{object_to_be_parsed.inspect}"
    logger.debug { message }
    logger.debug { "Backtrace:\n#{e.backtrace}" }
    errors.add_to_base(message)
    self
  end
  
  def title
    "#{result_model} #{scraper_type&&scraper_type.sub('Scraper','').downcase} parser for " +
    (portal_system ? portal_system.name : 'single scraper only')
  end
  
  protected
  def eval_parsing_code(code=nil, item=nil)
    base_url = @current_scraper.try(:base_url)
    # Wraps in new thread with higher $SAFE level as per Pickaxe, 
    # ... poss investigate using proc as per http://www.davidflanagan.com/2008/11/safe-is-proc-lo.html
    code_to_eval = code.dup
    code_to_eval.untaint # like code it will tainted as it was submitted in form. Can't eval tainted string
    thread = Thread.start do
      $SAFE = 2
      begin
        eval(code_to_eval)
      rescue Exception => e
        logger.debug { "********Exception raised in thread: #{e.message}\n#{e.backtrace}" }
        raise e
      end
      
    end
    thread.value # wait for the thread to finish and return value
  end
  
end
