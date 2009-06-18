class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string   :title
      t.text     :body
      t.string   :url
      t.integer  :document_owner_id
      t.string   :document_owner_type
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
