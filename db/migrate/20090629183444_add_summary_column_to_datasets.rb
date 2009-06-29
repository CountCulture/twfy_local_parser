class AddSummaryColumnToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :summary_column, :integer
  end

  def self.down
    remove_column :datasets, :summary_column
  end
end
