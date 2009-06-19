class AddRawBodyToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :raw_body, :text
  end

  def self.down
    remove_column :documents, :raw_body
  end
end
