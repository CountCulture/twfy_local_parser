class Meeting < ActiveRecord::Base
  belongs_to :committee
  validates_presence_of :date_held
  validates_uniqueness_of :date_held, :scope => :committee_id
  
  def title
    "#{committee.title}, #{date_held}"
  end
end
