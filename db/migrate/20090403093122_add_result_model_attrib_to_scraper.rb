class AddResultModelAttribToScraper < ActiveRecord::Migration
  def self.up
    add_column :scrapers, :result_model, :string
  end

  def self.down
    remove_column :scrapers, :result_model
  end
end
