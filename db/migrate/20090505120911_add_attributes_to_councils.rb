class AddAttributesToCouncils < ActiveRecord::Migration
  def self.up
    add_column :councils, :base_url, :string
    add_column :councils, :telephone, :string
    add_column :councils, :address, :text
    add_column :councils, :authority_type, :string
  end

  def self.down
    remove_column :councils, :authority_type
    remove_column :councils, :address
    remove_column :councils, :telephone
    remove_column :councils, :base_url
  end
end
