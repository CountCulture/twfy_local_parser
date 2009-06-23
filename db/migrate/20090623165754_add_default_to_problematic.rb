class AddDefaultToProblematic < ActiveRecord::Migration
  def self.up
    change_column_default :scrapers, :problematic, false
    Scraper.update_all(:problematic => false)
  end

  def self.down
  end
end
