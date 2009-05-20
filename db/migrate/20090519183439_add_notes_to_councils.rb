class AddNotesToCouncils < ActiveRecord::Migration
  def self.up
    add_column :councils, :notes, :text
  end

  def self.down
    remove_column :councils, :notes
  end
end
