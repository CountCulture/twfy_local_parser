class Committee < ActiveRecord::Base
  include ScrapedModel
  validates_presence_of :title, :url, :uid, :council_id
  validates_uniqueness_of :title
  belongs_to :council
  has_many :meetings
  has_many :memberships
  has_many :members, :through => :memberships
end
