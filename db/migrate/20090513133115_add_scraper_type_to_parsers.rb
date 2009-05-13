class AddScraperTypeToParsers < ActiveRecord::Migration
  def self.up
    add_column :parsers, :scraper_type, :string
    Parser.all.each { |p| p.update_attribute(:scraper_type, p.scrapers.first.class.to_s) }
  end

  def self.down
    remove_column :parsers, :scraper_type
  end
end
