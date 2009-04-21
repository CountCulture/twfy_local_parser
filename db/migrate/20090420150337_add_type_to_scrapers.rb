class AddTypeToScrapers < ActiveRecord::Migration
  def self.up
    add_column :scrapers, :type, :string
    Scraper.all{ |s| s.update_attribute(:type, "ItemScraper") }
  end

  def self.down
    remove_column :scrapers, :type
  end
end
