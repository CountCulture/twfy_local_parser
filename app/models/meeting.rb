class Meeting < ActiveRecord::Base
  include ScrapedModel
  belongs_to :committee
  belongs_to :council
  has_one :minutes, :class_name => "Document", :as => "document_owner"
  validates_presence_of :date_held, :committee_id, :uid, :council_id
  validates_uniqueness_of :uid, :scope => :council_id
  
  def title
    "#{committee.title} meeting, #{date_held.to_s(:custom_long).squish}"
  end
  
  def minutes_body=(doc_body=nil)
    minutes ? minutes.update_attribute(:body, doc_body) : create_minutes(:body => doc_body, :url => url)
  end
end
