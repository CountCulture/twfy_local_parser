class PortalSystem < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :councils
  has_many :parsers
  alias_attribute :title, :name
end
