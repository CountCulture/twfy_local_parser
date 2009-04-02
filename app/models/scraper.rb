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
  
  def expected_result_attributes
    read_attribute(:expected_result_attributes) ? Hash.new.instance_eval("merge(#{read_attribute(:expected_result_attributes)})") : {}
  end
  
  def update(item)
    results = parser.process(_data)
    item.update_with(results)
  end
  
  def test
    results = parser.process(_data)
    errors.add(:expected_result_class, "was #{expected_result_class}, but actual result class was #{results.class}") unless expected_result_class.blank? || results.class.to_s == expected_result_class
    errors.add(:expected_result_size, "was #{expected_result_size}, but actual result size was #{results.size}") unless expected_result_size.blank? || !results.is_a?(Array) || results.size == expected_result_size
    expected_result_attributes.each do |key,value|
      if results.is_a?(Array)
        results.each { |result|  match_attribute(result, key, value) }
      else
        match_attribute(results, key, value)
      end
      # case value 
      # when TrueClass
      #   message = "weren't matched: :#{key} expected but was missing or nil" unless results[key]
      # when Class
      #   message = "weren't matched: :#{key} expected to be #{value} but was #{results[key].class}" unless results[key].class.to_s == value
      # when Regexp
      #   message = "weren't matched: :#{key} expected to match /#{value.source}/ but was '#{results[key]}'" unless results[key].class.to_s == value
      # end
      # errors.add(:expected_result_attributes, message) if message
    end
    self
  end
  
  protected
  def _data
    Hpricot(_http_get(url))
  end
  
  def _http_get
  
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
