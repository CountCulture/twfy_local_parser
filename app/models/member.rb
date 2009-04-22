#atttributes url, constituency, party

class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :url, :uid
  validates_uniqueness_of :uid, :scope => :council_id # uid is unique id number assigned by council. It's possible that some councils may not assign them (e.g. GLA), but cross that bridge...
  has_many :memberships
  has_many :committees, :through => :memberships
  belongs_to :council
  named_scope :current, :conditions => "date_left IS NULL"
    
  def self.build_or_update(params)
    existing_member = find_existing(params)
    existing_member.attributes = params if existing_member
    existing_member || Member.new(params)
  end
  
  def self.create_or_update_and_save(params)
    member = self.build_or_update(params)
    # changed_attributes = member.send(:changed_attributes).clone
    member.save_without_losing_dirty
    # member.send(:changed_attributes).update(changed_attributes) # so merge them back in
    member
  end
  
  def self.create_or_update_and_save!(params)
    member = self.build_or_update(params)
    changed_attributes = member.send(:changed_attributes).clone
    member.save!# this clears changed attributes
    member.send(:changed_attributes).update(changed_attributes) # so merge them back in
    member
  end
  
  def self.find_existing(params)
    find_by_council_id_and_uid(params[:council_id], params[:uid])
  end
  
  def full_name=(full_name)
    names_hash = NameParser.parse(full_name)
    %w(first_name last_name title qualifications).each do |a|
      self.send("#{a}=", names_hash[a.to_sym])
    end
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def ex_member?
    date_left
  end
  
  def new_record_before_save?
    instance_variable_get(:@new_record_before_save)
  end
  
  def save_without_losing_dirty
    ch_attributes = changed_attributes.clone
    save # this clears changed attributes
    changed_attributes.update(ch_attributes) # so merge them back in
  end
end
