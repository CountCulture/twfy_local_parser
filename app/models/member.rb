class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :url
  validates_uniqueness_of :first_name, :scope => :last_name # assume all names will be unique for now. Scope later to party (no unique ids on GLA website)
  has_many :memberships
  has_many :committees, :through => :memberships
  
  # Gets list of members from GLA website and updates members. Ones no 
  # longer on website are marked as inactive
  def self.update_members
    scraped_members = Gla::MembersScraper.new.response
    scraped_members.each do |s_hash|
      m = Member.create(s_hash)
      if m.new_record? # then we didn't save
        find_by_first_name_and_last_name(m.first_name, m.last_name).update_attributes(s_hash)
      end
    end
  end
  
  def full_name=(full_name)
    names = full_name.split(" ")
    self.first_name = names[0..-2].join(" ")
    self.last_name = names.last
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def ex_member?
    date_left
  end
end
