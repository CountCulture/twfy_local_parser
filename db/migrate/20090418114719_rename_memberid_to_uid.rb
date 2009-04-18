class RenameMemberidToUid < ActiveRecord::Migration
  def self.up
    rename_column :members, :member_id, :uid
  end

  def self.down
    rename_column :members, :uid, :member_id
  end
end
