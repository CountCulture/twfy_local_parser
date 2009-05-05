class AddRelatedModelToScraper < ActiveRecord::Migration
  def self.up
    add_column :scrapers, :related_model, :string
  end

  def self.down
    remove_column :scrapers, :related_model
  end
end
