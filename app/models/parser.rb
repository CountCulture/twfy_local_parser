#attributes parsing_code, title

class Parser < ActiveRecord::Base
  has_many :scrapers
  validates_presence_of :title, :parsing_code
  # has_many :committee_scrapers
  
end
