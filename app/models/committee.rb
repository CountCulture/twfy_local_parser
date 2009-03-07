class Committee < ActiveRecord::Base
  validates_presence_of :title, :url
  validates_uniqueness_of :title
  has_many :meetings

end
