class AddWikipediaUrlToCouncils < ActiveRecord::Migration
  def self.up
    add_column :councils, :wikipedia_url, :string
    add_column :councils, :ons_url, :string
  end

  def self.down
    remove_column :councils, :ons_url
    remove_column :councils, :wikipedia_url
  end
end
