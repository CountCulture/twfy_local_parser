class Datapoint < ActiveRecord::Base
  belongs_to :council
  belongs_to :dataset
  validates_presence_of :data, :council_id, :dataset_id
  serialize :data
  delegate :summary_column, :to => :dataset
  
  def summary
    data.collect{ |d| d[summary_column] } if summary_column
  end
end
