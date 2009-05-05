class CreatePortalSystems < ActiveRecord::Migration
  def self.up
    create_table :portal_systems do |t|
      t.string :name
      t.string :url
      t.text :notes

      t.timestamps
    end
    add_column :councils, :portal_system_id, :integer
    add_column :parsers, :portal_system_id, :integer
  end

  def self.down
    remove_column :parsers, :portal_system_id
    remove_column :councils, :portal_system_id
    drop_table :portal_systems
  end
end
