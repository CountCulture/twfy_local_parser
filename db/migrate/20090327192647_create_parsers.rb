class CreateParsers < ActiveRecord::Migration
  def self.up
    create_table :parsers do |t|
      t.string    :title
      t.text      :parsing_code
      t.timestamps
    end
  end

  def self.down
    drop_table :parsers
  end
end
