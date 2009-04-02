class AddExpectedsToScraper < ActiveRecord::Migration
  def self.up
    add_column :scrapers, :expected_result_class, :string
    add_column :scrapers, :expected_result_size, :integer
    add_column :scrapers, :expected_result_attributes, :text
  end

  def self.down
    remove_column :scrapers, :expected_result_attributes
    remove_column :scrapers, :expected_result_size
    remove_column :scrapers, :expected_result_class
  end
end
