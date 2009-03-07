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
      @base_response = Hpricot(_http_get(base_url + target_page))
    end
    
    protected
    def _http_get(url)
      
    end
  end
  
  class MembersScraper < Scraper
    
    def response
      super
      members = []
      member_tables = @base_response.search("table table")
      constituency_members = member_tables.first.search("tr")[1..-1]
      london_wide_members = member_tables.last.search("tr")[1..-1]
      members += constituency_members.collect{ |m| Member.new( :full_name => m.at("td[2]").inner_text.strip, 
                                                               :constituency => m.at("td[1]").inner_text.strip, 
                                                               :party => m.at("td[3]").inner_text.strip ) }
      members += london_wide_members.collect{ |m| Member.new( :full_name => m.at("td[1]").inner_text.strip, 
                                                              :party => m.at("td[2]").inner_text.strip ) }
    end
  end
end