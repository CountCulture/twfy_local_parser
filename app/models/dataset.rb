class Dataset < ActiveRecord::Base
  BASE_URL = 'http://spreadsheets.google.com/'
  has_many :datapoints
  validates_presence_of :title, :key, :query
  
  def data_for(council)
    raw_response = _http_get(query_url(council))
    FasterCSV.parse(raw_response, :headers => true).by_col.collect{|c| c.flatten} unless raw_response.blank?
  end
  
  def process
    raw_response = _http_get(query_url)
    return if raw_response.blank?
    rows = FasterCSV.parse(raw_response, :headers => true).to_a
    header_row = rows.shift
    all_councils = Council.find(:all)
    all_councils.each do |council|
      c_row = rows.detect { |row_data| row_data.first.match(council.short_name) }
      if c_row
        dp = council.datapoints.find_or_initialize_by_dataset_id(id)
        dp.update_attributes(:data => [header_row, c_row])
      end
    end
  end
  
  # This is the url where original datasheet in spreadsheet can be seen
  def public_url
    BASE_URL + "pub?key=#{key}"
  end
  
  # This is the url for make a query through google visualization api
  def query_url(council=nil)
    BASE_URL + 'tq?tqx=out:csv&tq=' + CGI.escape(query + (council ? " where A contains '#{council.short_name}'" : '')) + "&key=#{key}"
  end
  
  protected
  def _http_get(url)
    return false if RAILS_ENV=="test"  # make sure we don't call make calls to external services in test environment. Mock this method to simulate response instead
    open(url)
  end
end
