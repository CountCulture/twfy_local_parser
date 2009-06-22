class AddDeclarationOfInterestsToMember < ActiveRecord::Migration
  def self.up
    add_column :members, :declaration_of_interests, :string
  end

  def self.down
    remove_column :members, :declaration_of_interests
  end
end
