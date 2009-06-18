class Document < ActiveRecord::Base
  validates_presence_of :body
  validates_presence_of :url
  validates_uniqueness_of :url
  belongs_to :document_owner, :polymorphic => true
end
