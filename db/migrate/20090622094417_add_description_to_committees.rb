class AddDescriptionToCommittees < ActiveRecord::Migration
  def self.up
    add_column :committees, :description, :text
  end

  def self.down
    remove_column :committees, :description
  end
end
