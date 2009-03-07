class AddEmailToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :email, :string
    add_column :members, :telephone, :string
  end

  def self.down
    remove_column :members, :telephone
    remove_column :members, :email
  end
end
