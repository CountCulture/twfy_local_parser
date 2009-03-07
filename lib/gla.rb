module Gla
  class Scraper
    BASE_URL = "http://www.london.gov.uk"
    attr_reader :target_page
    
    def initialize(params={})
      @target_page = params[:target_page]
    end
    
    def base_url
      BASE_URL
    end
    
    def response
      Hpricot(_http_get(base_url + target_page))
    end
    
    protected
    def _http_get(url)
      
    end
  end
end