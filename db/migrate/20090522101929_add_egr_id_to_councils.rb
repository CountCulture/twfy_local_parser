class AddEgrIdToCouncils < ActiveRecord::Migration
  def self.up
    add_column :councils, :egr_id, :integer
  end

  def self.down
    remove_column :councils, :egr_id
  end
end
