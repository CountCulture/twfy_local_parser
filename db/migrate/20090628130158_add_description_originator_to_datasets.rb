class AddDescriptionOriginatorToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :description, :text
    add_column :datasets, :originator, :string
    add_column :datasets, :originator_url, :string
  end

  def self.down
    remove_column :datasets, :originator_url
    remove_column :datasets, :originator
    remove_column :datasets, :description
  end
end
