class AddCommitteesRelationshipToMeetings < ActiveRecord::Migration
  def self.up
    add_column :meetings, :committee_id, :integer
  end

  def self.down
    remove_column :meetings, :committee_id
  end
end
