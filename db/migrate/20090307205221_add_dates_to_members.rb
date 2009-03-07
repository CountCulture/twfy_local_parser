class AddDatesToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :date_elected, :date
    add_column :members, :date_left, :date
  end

  def self.down
    remove_column :members, :date_left
    remove_column :members, :date_elected
  end
end
