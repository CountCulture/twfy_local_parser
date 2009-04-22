class RenameMembersTitleAsNameTitle < ActiveRecord::Migration
  def self.up
    rename_column :members, :title, :name_title
  end

  def self.down
    rename_column :members, :name_title, :title
  end
end
