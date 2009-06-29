class Datapoint < ActiveRecord::Base
  belongs_to :council
  belongs_to :dataset
  validates_presence_of :data
  serialize :data
end
