class TweakDatapointsAndDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :last_checked, :datetime
    remove_column :datapoints, :data_summary
  end

  def self.down
    remove_column :datasets, :last_checked
    add_column :datapoints, :data_summary, :string
  end
end
