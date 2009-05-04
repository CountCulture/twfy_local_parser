class Committee < ActiveRecord::Base
  include ScrapedModel
  validates_presence_of :title, :url, :uid, :council_id
  validates_uniqueness_of :title, :scope => :council_id
  belongs_to :council
  has_many :meetings
  has_many :memberships, :primary_key => :uid
  has_many :members, :through => :memberships do
    def add_or_update(members)
      
    end
    
    def uids=(uid_array)
      uid_members = proxy_reflection.source_reflection.klass.find_all_by_uid_and_council_id(uid_array, proxy_owner.council_id)
      proxy_owner.send("#{proxy_reflection.name}=",uid_members)
    end
    
    def uids
      collect(&:uid)
    end
  end
  delegate :uids, :to => :members, :prefix => true
  delegate :uids=, :to => :members, :prefix => true
end
