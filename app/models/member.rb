#atttributes url, constituency, party

class Member < ActiveRecord::Base
  include ScrapedModel
  validates_presence_of :first_name, :last_name, :url, :uid, :council_id
  validates_uniqueness_of :uid, :scope => :council_id # uid is unique id number assigned by council. It's possible that some councils may not assign them (e.g. GLA), but cross that bridge...
  has_many :memberships
  has_many :committees, :through => :memberships
  belongs_to :council
  named_scope :current, :conditions => "date_left IS NULL"
  alias_attribute :title, :full_name
      
  
  def full_name=(full_name)
    names_hash = NameParser.parse(full_name)
    %w(first_name last_name name_title qualifications).each do |a|
      self.send("#{a}=", names_hash[a.to_sym])
    end
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def ex_member?
    date_left
  end
  
end
