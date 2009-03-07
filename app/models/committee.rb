class Committee < ActiveRecord::Base
  validates_presence_of :title, :url
  validates_uniqueness_of :title
  has_many :meetings
  has_many :memberships
  has_many :members, :through => :memberships
end
