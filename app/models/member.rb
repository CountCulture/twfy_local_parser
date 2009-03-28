#atttributes url, constituency, party

class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :url
  validates_uniqueness_of :first_name, :scope => :last_name # assume all names will be unique for now. Scope later to party (no unique ids on GLA website)
  has_many :memberships
  has_many :committees, :through => :memberships
  belongs_to :council
  named_scope :current, :conditions => "date_left IS NULL"
  
  # Gets list of members from GLA website and updates members. Ones no 
  # longer on website are marked as inactive
  def self.update_members
    existing_members = self.current
    scraped_members = Gla::MembersScraper.new.response
    existing_members.each do |member|
      new_attribs = scraped_members.detect{ |sm| sm[:full_name] == member.full_name }
      if new_attribs
        scraped_members - [new_attribs]
        # m.update_attributes(new_attribs)
      else
        member.update_attribute(:date_left, Date.today) 
      end
    end
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
