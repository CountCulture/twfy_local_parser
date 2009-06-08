# attributes: url wikipedia_url location website_generator

class Council < ActiveRecord::Base
  has_many :members
  has_many :committees
  has_many :scrapers
  has_many :meetings
  belongs_to :portal_system
  validates_presence_of :name
  validates_uniqueness_of :name
  alias_attribute :title, :name
  
  def base_url
    read_attribute(:base_url) || url
  end
  
  def self.parsed
    find(:all, :conditions => "members.council_id = councils.id", :joins => "INNER JOIN members", :group => "councils.id")
  end
  
  def parsed?
    !members.blank?
  end
  
  def short_name
    name.gsub(/Borough|City|Royal|London|of/, '').strip
  end
end
