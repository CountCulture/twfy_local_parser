class CreateMeetings < ActiveRecord::Migration
  def self.up
    create_table :meetings do |t|
      t.date :date_held
      t.string :agenda_url
      t.string :minutes_pdf
      t.string :minutes_rtf

      t.timestamps
    end
  end

  def self.down
    drop_table :meetings
  end
end
