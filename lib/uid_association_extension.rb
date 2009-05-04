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