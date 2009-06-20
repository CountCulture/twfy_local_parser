class AddDocumentTypeToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :document_type, :string
  end

  def self.down
    remove_column :documents, :document_type
  end
end
