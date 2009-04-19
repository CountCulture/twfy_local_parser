#atttributes url, constituency, party

class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :url, :uid
  validates_uniqueness_of :uid, :scope => :council_id # uid is unique id number assigned by council. It's possible that some councils may not assign them (e.g. GLA), but cross that bridge...
  has_many :memberships
  has_many :committees, :through => :memberships
  belongs_to :council
  named_scope :current, :conditions => "date_left IS NULL"
  
  # Gets list of members from GLA website and updates members. Ones no 
  # longer on website are marked as inactive
  # def self.update_members
  #   existing_members = self.current
  #   scraped_members = Gla::MembersScraper.new.response
  #   existing_members.each do |member|
  #     new_attribs = scraped_members.detect{ |sm| sm[:full_name] == member.full_name }
  #     if new_attribs
  #       scraped_members - [new_attribs]
  #       # m.update_attributes(new_attribs)
  #     else
  #       member.update_attribute(:date_left, Date.today) 
  #     end
  #   end
  #   scraped_members.each do |s_hash|
  #     m = Member.create(s_hash)
  #     if m.new_record? # then we didn't save
  #       find_by_first_name_and_last_name(m.first_name, m.last_name).update_attributes(s_hash)
  #     end
  #   end
  # end
  
  def self.build_or_update(params)
    existing_member = find_existing(params)
    existing_member.attributes = params if existing_member
    existing_member || Member.new(params)
  end
  
  def self.create_or_update_and_save(params)
    member = self.build_or_update(params)
    member.save
    member
  end
  
  def self.create_or_update_and_save!(params)
    member = self.build_or_update(params)
    member.save!
    member
  end
  
  def self.find_existing(params)
    find_by_council_id_and_uid(params[:council_id], params[:uid])
  end
  
  def full_name=(full_name)
    names_hash = NameParser.parse(full_name)
    self.first_name = names_hash[:first_name]
    self.last_name = names_hash[:last_name]
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def ex_member?
    date_left
  end
  
end
