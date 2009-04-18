#atttributes url, constituency, party

class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :url
  validates_uniqueness_of :first_name, :scope => [:last_name, :council_id ]# assume all names will be unique to council for now. Scope later to party (no unique ids on GLA website)
  validates_uniqueness_of :member_id, :scope => :council_id, :allow_nil => true # Member id is unique id number assigned by council, but some councils may not assign them
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
  
  def self.build_or_update(params)
    first_name, last_name = names_from_fullname(params[:full_name])
    existing_member = find_by_council_id_and_first_name_and_last_name(params[:council_id], first_name, last_name)
    existing_member.attributes = params if existing_member
    existing_member || Member.new(params)
  end
  
  def self.create_or_update_and_save(params)
    first_name, last_name = names_from_fullname(params[:full_name])
    existing_member = find_by_council_id_and_first_name_and_last_name(params[:council_id], first_name, last_name)
    existing_member.update_attributes(params) if existing_member
    existing_member || Member.create(params)
  end
  
  # def self.create_or_update_and_save!(params)
  #   first_name, last_name = names_from_fullname(params[:full_name])
  #   existing_member = find_by_council_id_and_first_name_and_last_name(params[:council_id], first_name, last_name)
  #   existing_member.update_attributes!(params) if existing_member
  #   existing_member || Member.create!(params)
  # end
  
  def self.create_or_update_and_save!(params)
    member = self.build_or_update(params)
    member.save!
  end
  
  def full_name=(full_name)
    self.first_name, self.last_name = names_from_fullname(full_name)
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def ex_member?
    date_left
  end
  
  private
  def self.names_from_fullname(fn)
    names = fn.split(" ")
    first_name = names[0..-2].join(" ")
    last_name = names.last
    [first_name, last_name]
  end
  
  def names_from_fullname(fn)
    self.class.names_from_fullname(fn)
  end
end
