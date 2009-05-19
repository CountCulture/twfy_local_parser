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
end
