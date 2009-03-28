class CreateCouncils < ActiveRecord::Migration
  def self.up
    create_table :councils do |t|
      t.string      :name
      t.string      :url         
      t.timestamps
    end
    add_column :members, :council_id, :integer
    add_column :committees, :council_id, :integer
  end

  def self.down
    remove_column :members, :council_id
    remove_column :committees, :council_id
    drop_table :councils
  end
end
