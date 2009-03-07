class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :url
  def full_name=(full_name)
    names = full_name.split(" ")
    self.first_name = names[0..-2].join(" ")
    self.last_name = names.last
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
end
