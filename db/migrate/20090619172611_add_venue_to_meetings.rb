class AddVenueToMeetings < ActiveRecord::Migration
  def self.up
    add_column :meetings, :venue, :text
    remove_column :meetings, :minutes_rtf
    remove_column :meetings, :minutes_pdf
    remove_column :meetings, :agenda_url
  end

  def self.down
    add_column :meetings, :agenda_url, :string
    add_column :meetings, :minutes_pdf, :string
    add_column :meetings, :minutes_rtf, :string
    remove_column :meetings, :venue
  end
end
