class AddLastScrapedToScrapers < ActiveRecord::Migration
  def self.up
    add_column :scrapers, :last_scraped, :datetime
  end

  def self.down
    remove_column :scrapers, :last_scraped
  end
end
