module Gla
  class Scraper
    BASE_URL = "http://www.london.gov.uk/assembly/"
    
    def initialize(params={})
      @target_page = params[:target_page]
    end
    
    def base_url
      BASE_URL
    end
    
    def response
      @base_response = Hpricot(_http_get(base_url + target_page.to_s))
    end
    
    def target_page
      @target_page || (self.class.const_defined?(:TARGET_PAGE) ? self.class::TARGET_PAGE : nil)
    end
    
    protected
    def _http_get(url)
      open(url)
    end
  end
  
  class MembersScraper < Scraper
    TARGET_PAGE = "lams_facts_cont.jsp"
    
    def response
      super
      members = []
      member_tables = @base_response.search("table table")
      constituency_members = member_tables.first.search("tr")[1..-1]
      london_wide_members = member_tables.last.search("tr")[1..-1]
      members += constituency_members.collect{ |m| { :full_name => m.at("td[2]").inner_text.strip, 
                                                     :constituency => m.at("td[1]").inner_text.strip, 
                                                     :party => m.at("td[3]").inner_text.strip,
                                                     :url => m.at("a")[:href] } }
      members += london_wide_members.collect{ |m| { :full_name => m.at("td[1]").inner_text.strip, 
                                                    :party => m.at("td[2]").inner_text.strip,
                                                    :url => m.at("a")[:href] } }
    end
  end
  
  class MemberScraper < Scraper
    
    def response
      super
      email_node = @base_response.at("table a[@href^=mailto]")
      email = email_node[:href].sub('mailto:','')
      telephone = email_node.parent.children.first.inner_text.scan(/[\d\s]+/).first
      member = Member.new(:email => email, :telephone  =>  telephone.strip)
    end
  end
  
  class CommitteesScraper < Scraper
    
    def response
      super
      current_committees = @base_response.search('table ul li')
      current_committees.collect{ |c| Committee.new( :title => c.at("a").inner_text,
                                                     :url => c.at("a")[:href] ) }
    end
  end
  
  class CommitteeScraper < Scraper

    def response
      super
      committee = Committee.new
    end
  end
end