class AddTitleEtcToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :title, :string
    add_column :members, :qualifications, :string
  end

  def self.down
    remove_column :members, :qualifications
    remove_column :members, :title
  end
end
