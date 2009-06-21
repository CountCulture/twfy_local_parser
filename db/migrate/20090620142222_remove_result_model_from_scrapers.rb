class RemoveResultModelFromScrapers < ActiveRecord::Migration
  def self.up
    remove_column :scrapers, :result_model
  end

  def self.down
    add_column :scrapers, :result_model, :string
  end
end
