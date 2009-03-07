class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :member_id
      t.integer :committee_id
      t.date :date_joined
      t.date :date_left
      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end
