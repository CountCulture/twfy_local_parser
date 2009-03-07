class AddUrlToCommittees < ActiveRecord::Migration
  def self.up
    add_column :committees, :url, :string
  end

  def self.down
    remove_column :committees, :url
  end
end
