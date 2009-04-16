class AddMemberIdToMembersTable < ActiveRecord::Migration
  def self.up
    add_column :members, :member_id, :integer
  end

  def self.down
    remove_column :members, :member_id
  end
end
