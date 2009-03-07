class Meeting < ActiveRecord::Base
  belongs_to :committee
  validates_presence_of :date_held
end
