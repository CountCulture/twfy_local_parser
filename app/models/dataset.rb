class Dataset < ActiveRecord::Base
  BASE_URL = 'http://spreadsheets.google.com/tq?tqx=out:csv'
  
  validates_presence_of :title, :key, :query
  
  def data_for(council)
    response = FasterCSV.parse(_http_get(query_url(council)), :headers => true).by_col.collect{|c| c.flatten}
  end
  
  def query_url(council=nil)
    BASE_URL + '&tq=' + CGI.escape(query + (council ? " where A contains '#{council.short_name}'" : '')) + "&key=#{key}"
  end
  
  protected
  def _http_get(url)
    return false if RAILS_ENV=="test"  # make sure we don't call make calls to external services in test environment. Mock this method to simulate response instead
    open(url)
  end
end