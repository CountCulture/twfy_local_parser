class ItemScraper < Scraper
  validates_presence_of :url, :if => Proc.new { |i| i.related_model.blank? }
  
  def process(options={})
    if related_model.blank?
      super
    else
      related_objects.each do |obj|
        target_url = url.blank? ? obj.url : obj.instance_eval("\"" + url + "\"") # if we have url evaluate it AS A STRING in context of related object (which allows us to interpolate uid etc), otherwise just use related object's url
        raw_results = parser.process(_data(target_url)).results
        update_with_results(raw_results.collect{ |r| r.merge("#{obj.class.to_s.downcase}_id".to_sym => obj.id) }, options) unless raw_results.blank?
      end
      self
    end
  end

  def related_objects
    @related_objects ||= related_model.constantize.find(:all, :conditions => { :council_id => council_id })
  end
  
  def scraping_for
    "#{result_model}s from #{url}"
  end
    
end