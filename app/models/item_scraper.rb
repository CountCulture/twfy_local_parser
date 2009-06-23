class ItemScraper < Scraper
  # validates_presence_of :url, :if => Proc.new { |i| i.related_model.blank? }
  
  def process(options={})
    if related_model.blank?
      super
    else
      related_objects.each do |obj|
        target_url = url.blank? ? obj.url : obj.instance_eval("\"" + url + "\"") # if we have url evaluate it AS A STRING in context of related object (which allows us to interpolate uid etc), otherwise just use related object's url
        raw_results = parser.process(_data(target_url), self).results
        logger.debug { "\n\n**************RESULTS from parsing #{target_url}:\n#{raw_results.inspect}" }
        update_with_results(raw_results.collect{ |r| r.merge("#{obj.class.to_s.downcase}_id".to_sym => obj.id) }, options) unless raw_results.blank?
      end
      update_last_scraped if options[:save_results]&&parser.errors.empty?
      mark_as_problematic unless parser.errors.empty?
      self
    end
  rescue ScraperError => e
    logger.debug { "*******#{e.message} while processing #{self.inspect}" }
    errors.add_to_base(e.message)
    mark_as_problematic
    self
  end

  def related_objects
    @related_objects ||= related_model.constantize.find(:all, :conditions => { :council_id => council_id })
  end
  
  def scraping_for
    "#{result_model}s from #{url}"
  end
    
end