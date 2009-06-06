class Scraper < ActiveRecord::Base
  class ScraperError < StandardError; end
  class RequestError < ScraperError; end
  class ParsingError < ScraperError; end
  SCRAPER_TYPES = %w(InfoScraper ItemScraper)
  belongs_to :parser
  belongs_to :council
  validates_presence_of :council_id

  accepts_nested_attributes_for :parser
  attr_accessor :related_objects, :parsing_results
  attr_protected :results
  delegate :result_model, :to => :parser
  delegate :related_model, :to => :parser
  delegate :portal_system, :to => :council
  delegate :base_url, :to => :council
  
  def validate
    errors.add(:parser, "can't be blank") unless parser
  end
  
  def computed_url
    !base_url.blank?&&!parser.path.blank? ? "#{base_url}#{parser.path}" : nil
  end
  
  def expected_result_attributes
    read_attribute(:expected_result_attributes) ? Hash.new.instance_eval("merge(#{read_attribute(:expected_result_attributes)})") : {}
  end
  
  def title
    getting = self.is_a?(InfoScraper) ? 'Info' : 'Items'
    "#{result_model} #{getting} scraper for #{council.name} council"
  end
  
  def parsing_errors
    parser.errors
  end
  
  # Returns true if associated parser belons to portal_system, false otherwise
  def portal_parser?
    !!parser.try(:portal_system)
  end
  
  def possible_parsers
    portal_system.parsers
  end
  
  def process(options={})
    self.parsing_results = parser.process(_data(url), self).results
    update_with_results(parsing_results, options)
    self
  end
  
  def results
    @results ||=[]
  end
  
  # build url from council's base_url and parsers path unless url is set
  def url
    read_attribute(:url).blank? ? computed_url : read_attribute(:url)
  end
  
  protected
  def _data(target_url=nil)
    Hpricot.parse(_http_get(target_url), :fixup_tags => true)
  rescue Exception => e
    logger.error { "Problem with data returned from #{target_url}: #{e}" }
    raise ParsingError
  end
  
  def _http_get(target_url)
    return false if RAILS_ENV=="test"  # make sure we don't call make calls to external services in test environment. Mock this method to simulate response instead
    # response = nil 
    # target_url = URI.parse(target_url)
    # request = Net::HTTP.new(target_url.host, target_url.port)
    # request.read_timeout = 5 # set timeout at 5 seconds
    # begin
    #   response = request.get(target_url.request_uri)
    #   raise RequestError, "Problem retrieving info from #{target_url}." unless response.is_a? Net::HTTPSuccess
    # rescue Timeout::Error
    #   raise RequestError, "Timeout::Error retrieving info from #{target_url}."
    # end
    open(target_url).read
    # logger.debug "********Scraper response = #{response.body.inspect}"
    # response.body
  end
  
  # def match_attribute(result, key, value)
  #   case value 
  #   when TrueClass
  #     message = "weren't matched: :#{key} expected but was missing or nil" unless result[key]
  #   when Class
  #     message = "weren't matched: :#{key} expected to be #{value} but was #{result[key].class}" unless result[key].is_a?(value)
  #   when Regexp
  #     message = "weren't matched: :#{key} expected to match /#{value.source}/ but was '#{result[key]}'" unless result[key] =~ value
  #   end
  #   errors.add(:expected_result_attributes, message) if message
  # end
  
  def update_with_results(parsing_results, options={})
    unless parsing_results.blank?
      parsing_results.each do |result|
        item = result_model.constantize.build_or_update(result.merge(:council_id => council.id))
        options[:save_results] ? item.save_without_losing_dirty : item.valid? # we want to know what's changed and keep any errors, so run save_without_losing_dirty if we're saving, run validation to add errors to item otherwise
        results << item
      end
    end
  end
  
end
