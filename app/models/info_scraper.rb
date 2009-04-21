class InfoScraper < Scraper
  
  # partially overrides test method defined in Scraper class to set info object
  # instance variable
  def test(info_object)
    @info_object = info_object
    super
  end
  
  # partially overrides test method defined in Scraper class to set info object
  # instance variable
  def update_from_url(info_object)
    @info_object = info_object
    super
  end
  
  # overrides url accessor/attribute and uses url from info_object instead
  def url
    @info_object&&@info_object.url 
  end
  
  protected
  # overrides method in standard scraper
  def update_with_test_results
    @info_object.attributes = parsing_results.first
    @info_object.valid?
    @results = [@info_object]
  end
  
  # overrides standard scraper method
  def update_with_update_results
    @info_object.update_attributes(parsing_results.first)
    @results = [@info_object]
  end
end