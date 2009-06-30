# attributes: url wikipedia_url location website_generator

class Council < ActiveRecord::Base
  has_many :members
  has_many :committees
  has_many :scrapers
  has_many :meetings
  has_many :datapoints
  has_many :datasets, :through => :datapoints#, :source => :join_association_table_foreign_key_to_datasets_table
  belongs_to :portal_system
  validates_presence_of :name
  validates_uniqueness_of :name
  named_scope :parsed, :conditions => "members.council_id = councils.id", :joins => "INNER JOIN members", :group => "councils.id"
  default_scope :order => "name"
  alias_attribute :title, :name
  
  def base_url
    read_attribute(:base_url) || url
  end
  
  def parsed?
    !members.blank?
  end
  
  def short_name
    name.gsub(/Borough|City|Royal|London|of/, '').strip
  end
end
