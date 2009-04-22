class AddUidToCommittees < ActiveRecord::Migration
  def self.up
    add_column :committees, :uid, :integer
  end

  def self.down
    remove_column :committees, :uid
  end
end
