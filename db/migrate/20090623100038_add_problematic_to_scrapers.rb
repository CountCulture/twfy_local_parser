class AddProblematicToScrapers < ActiveRecord::Migration
  def self.up
    add_column :scrapers, :problematic, :boolean
  end

  def self.down
    remove_column :scrapers, :problematic
  end
end
