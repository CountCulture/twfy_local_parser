class AddUidEtcToMeetings < ActiveRecord::Migration
  def self.up
    add_column :meetings, :uid, :integer
    add_column :meetings, :council_id, :integer
    add_column :meetings, :url, :string
  end

  def self.down
    remove_column :meetings, :council_id
    remove_column :meetings, :uid
  end
end
