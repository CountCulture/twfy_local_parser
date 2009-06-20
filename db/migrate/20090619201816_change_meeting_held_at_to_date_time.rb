class ChangeMeetingHeldAtToDateTime < ActiveRecord::Migration
  def self.up
    change_column :meetings, :date_held, :datetime
  end

  def self.down
    change_column :meetings, :date_held, :date
  end
end
