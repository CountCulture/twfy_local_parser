class AddNotesToScrapers < ActiveRecord::Migration
  def self.up
    add_column :scrapers, :notes, :text
  end

  def self.down
    remove_column :scrapers, :notes
  end
end
