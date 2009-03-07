class AddUrlToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :url, :string
  end

  def self.down
    remove_column :members, :url
  end
end
