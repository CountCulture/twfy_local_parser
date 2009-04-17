#attributes: uri

class Scraper < ActiveRecord::Base
  class ScraperError < StandardError; end
  class RequestError < ScraperError; end
  class ParsingError < ScraperError; end
  ALLOWED_RESULT_CLASSES = %w(Member Members Committee Committees)
  belongs_to :parser
  belongs_to :council
  validates_presence_of :url
  validates_presence_of :council_id
  validates_presence_of :result_model
  validates_inclusion_of :result_model, :in => ALLOWED_RESULT_CLASSES, :message => "is invalid"
  # delegate :parsing_code, :to => :parser
  accepts_nested_attributes_for :parser
  attr_accessor :results, :parsing_results
  attr_protected :results
    
  def expected_result_attributes
    read_attribute(:expected_result_attributes) ? Hash.new.instance_eval("merge(#{read_attribute(:expected_result_attributes)})") : {}
  end
  
  # def update(item)
  #   results = parser.process(_data)
  #   item.update_with(results)
  # end
  
  def title
    "#{result_model} scraper for #{council.name} council"
  end
  
  def parsing_errors
    parser.errors
  end
  
  def process
    @parsing_results = parser.process(_data).results
  end
  
  def test
    @results = []
    self.process
    # logger.debug { "Parser results = #{parser.results.inspect}" }
    # parser_results = parser.process(_data)
    # errors.add(:expected_result_class, "was #{expected_result_class}, but actual result class was #{parser_results.class}") unless 
    #                                 expected_result_class.blank? || parser_results.class.to_s == expected_result_class
    # errors.add(:expected_result_size, "was #{expected_result_size}, but actual result size was #{parser_results.size}") unless 
    #                                 expected_result_size.blank? || !parser_results.is_a?(Array) || parser_results.size == expected_result_size
    # expected_result_attributes.each do |key,value|
    #   if parser_results.is_a?(Array)
    #     parser_results.each do |result|
    #       match_attribute(result, key, value)
    #     end
    #   else
    #     match_attribute(parser_results, key, value)
    #   end
    #   # case value 
    #   # when TrueClass
    #   #   message = "weren't matched: :#{key} expected but was missing or nil" unless results[key]
    #   # when Class
    #   #   message = "weren't matched: :#{key} expected to be #{value} but was #{results[key].class}" unless results[key].class.to_s == value
    #   # when Regexp
    #   #   message = "weren't matched: :#{key} expected to match /#{value.source}/ but was '#{results[key]}'" unless results[key].class.to_s == value
    #   # end
    #   # errors.add(:expected_result_attributes, message) if message
    # end
    unless parsing_results.blank?
      parsing_results.each do |result|
        item = result_model.constantize.build_or_update(result.merge(:council_id => council.id))
        item.valid? # check if valid and add errors to item
        @results << item
      end
    end
    self
  end
  
  def update_from_url
    @results = []
    self.process
    parsing_results.each do |result|
      item = result_model.constantize.create_or_update_and_save(result.merge(:council_id => council.id))
      @results << item
    end
    self
  end
  
  protected
  def _data
    Hpricot.parse(_http_get(url))
  rescue Exception => e
    logger.error { "Problem parsing data returned from #{url}: #{e}" }
    raise ParsingError
  end
  
  def _http_get(url)
    return false if RAILS_ENV=="test"  # make sure we don't call make calls to external services in test environment. Mock this method to simulate response instead
    response = nil 
     url = URI.parse(url)
     request = Net::HTTP.new(url.host, url.port)
     request.read_timeout = 5 # set timeout at 5 seconds
    begin
      response = request.get(url.request_uri)
      raise RequestError, "Problem retrieving info from #{url}." unless response.is_a? Net::HTTPSuccess
    rescue Timeout::Error
      raise RequestError, "Timeout::Error retrieving info from #{url}."
    end
    logger.debug "********Scraper response = #{response.body.inspect}"
    response.body
  end
  
  def match_attribute(result, key, value)
    case value 
    when TrueClass
      message = "weren't matched: :#{key} expected but was missing or nil" unless result[key]
    when Class
      message = "weren't matched: :#{key} expected to be #{value} but was #{result[key].class}" unless result[key].is_a?(value)
    when Regexp
      message = "weren't matched: :#{key} expected to match /#{value.source}/ but was '#{result[key]}'" unless result[key] =~ value
    end
    errors.add(:expected_result_attributes, message) if message
  end
end
