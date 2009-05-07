class MoveScraperAttribsToParser < ActiveRecord::Migration
  def self.up
    rename_column :parsers, :title, :description
    add_column :parsers, :result_model, :string
    add_column :parsers, :related_model, :string
    Scraper.find(:all).each { |s| s.parser.update_attributes(:result_model => s.result_model, :related_model => s.related_model)  }
  end

  def self.down
    # Scraper.find(:all).each { |s| s.update_attributes(:result_model => s.parser.result_model, :related_model => s.parser.related_model)  }
    # remove_column :parsers, :related_model
    # remove_column :parsers, :result_model
    rename_column :parsers, :description, :title
  end
end
