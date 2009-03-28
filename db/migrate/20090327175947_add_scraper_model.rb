class AddScraperModel < ActiveRecord::Migration
  def self.up
    create_table :scrapers, :force => true do |t|
      t.string :url
      t.integer :parser_id
      t.integer :council_id
      t.timestamps
    end
  end

  def self.down
    drop_table :scrapers
  end
end
