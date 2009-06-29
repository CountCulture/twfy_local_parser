class CreateDatapoints < ActiveRecord::Migration
  def self.up
    create_table :datapoints do |t|
      t.string  :data_summary
      t.text    :data
      t.integer :council_id
      t.integer :dataset_id
      t.timestamps
    end
  end

  def self.down
    drop_table :datapoints
  end
end
