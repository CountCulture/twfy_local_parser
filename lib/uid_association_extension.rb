# This module should be included in associations to allow relationships to be 
# set given just a collection of uids. So if we have in the Committee model:
# # has_many :members, :through => :memberships, :extend => UidAssociationExtension
# this will add: members.uids and members.uids= methods. For convenience these can
# be rewritten as members_uids and members_uids= using :delegate e.g.
# # delegate :uids, :to => :members, :prefix => "member" 
# which delegates the member_uids method to the uids method of the members 
# association.
# See http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
# for more details

module UidAssociationExtension
  def add_or_update(members)
    # not yet done
  end
  
  def uids=(uid_array)
    uid_members = proxy_reflection.source_reflection.klass.find_all_by_uid_and_council_id(uid_array, proxy_owner.council_id)
    proxy_owner.send("#{proxy_reflection.name}=",uid_members)
  end
  
  def uids
    collect(&:uid)
  end
  
end