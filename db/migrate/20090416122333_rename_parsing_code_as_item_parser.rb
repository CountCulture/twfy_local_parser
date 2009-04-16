class RenameParsingCodeAsItemParser < ActiveRecord::Migration
  def self.up
    rename_column :parsers, :parsing_code, :item_parser
    add_column :parsers, :attribute_parser, :text
  end

  def self.down
    remove_column :parsers, :attribute_parser
    rename_column :parsers, :item_parser, :parsing_code
  end
end
