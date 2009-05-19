class AddPathToParser < ActiveRecord::Migration
  def self.up
    add_column :parsers, :path, :string
  end

  def self.down
    remove_column :parsers, :path
  end
end
