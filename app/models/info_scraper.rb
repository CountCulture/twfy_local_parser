class InfoScraper < Scraper
  
  def process(options={})
    @related_objects = [options[:objects]].flatten if options[:objects]
    related_objects.each do |obj|
      raw_results = parser.process(_data(obj.url), self).results
      update_with_results(raw_results, obj, options)
    end
    self
  end
  
  def related_objects
    @related_objects ||= result_model.constantize.find(:all, :conditions => { :council_id => council_id })
  end
  
  def scraping_for
    "info on #{result_model}s"
  end
  
  protected
  # overrides method in standard scraper
  def update_with_results(res, obj=nil, options={})
    unless res.blank?
      obj.attributes = res.first
      options[:save_results] ? obj.save : obj.valid?
      results << obj
    end
  end

end