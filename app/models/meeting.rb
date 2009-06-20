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
    minutes ? minutes.update_attributes(:body => doc_body, :document_type => "Minutes") : create_minutes(:body => doc_body, :url => url, :document_type => "Minutes")
  end
end
