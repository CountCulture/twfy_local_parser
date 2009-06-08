class AddWdtkNameToCouncils < ActiveRecord::Migration
  def self.up
    add_column :councils, :wdtk_name, :string
  end

  def self.down
    remove_column :councils, :wdtk_name
  end
end
