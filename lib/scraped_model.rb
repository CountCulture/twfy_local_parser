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

  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end