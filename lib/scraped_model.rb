module ScrapedModel
  module ClassMethods
    
    # default find_existing. Overwrite in models that include this mixin if necessary
    def find_existing(params)
      find_by_council_id_and_uid(params[:council_id], params[:uid])
    end

    def build_or_update(params)
      existing_record = find_existing(params)
      existing_record.attributes = params if existing_record
      existing_record || self.new(params)
    end
    
    def create_or_update_and_save(params)
      updated_record = self.build_or_update(params)
      updated_record.save_without_losing_dirty
      updated_record
    end
    
    def create_or_update_and_save!(params)
      updated_record = build_or_update(params)
      updated_record.save_without_losing_dirty || raise(ActiveRecord::RecordNotSaved)
      updated_record
    end
  end
  
  module InstanceMethods
    def save_without_losing_dirty
      ch_attributes = changed_attributes.clone
      success = save # this clears changed attributes
      changed_attributes.update(ch_attributes) # so merge them back in
      success # return result of saving
    end
    
    def new_record_before_save?
      instance_variable_get(:@new_record_before_save)
    end

    protected
    # Updates timestamp of council when member details are updated, new member is added or deleted
    def mark_council_as_updated
      council.update_attribute(:updated_at, Time.now) if council
    end
  end
  
  def self.included(i_class)
    i_class.extend         ClassMethods
    i_class.send :include, InstanceMethods
    i_class.after_save :mark_council_as_updated
    i_class.after_destroy :mark_council_as_updated
  end
end