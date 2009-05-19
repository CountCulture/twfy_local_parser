class Meeting < ActiveRecord::Base
  include ScrapedModel
  belongs_to :committee
  belongs_to :council
  validates_presence_of :date_held, :committee_id, :uid, :council_id
  validates_uniqueness_of :uid, :scope => :council_id
  
  def title
    "#{committee.title}, #{date_held}"
  end
end
