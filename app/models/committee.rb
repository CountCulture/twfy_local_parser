class Committee < ActiveRecord::Base
  include ScrapedModel
  validates_presence_of :title, :url, :uid, :council_id
  validates_uniqueness_of :title, :scope => :council_id
  belongs_to :council
  has_many :meetings
  has_many :memberships, :primary_key => :uid
  has_many :members, :through => :memberships, :extend => UidAssociationExtension
  delegate :uids, :to => :members, :prefix => "member"
  delegate :uids=, :to => :members, :prefix => "member"
end
