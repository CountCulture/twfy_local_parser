module ScrapersHelper
  def class_for_result(res)
    css_class = 
      case 
      when res.new_record?
        "new"
      when res.changed?
        "changed"
      else
        "unchanged"
      end
    # css_class << "new" if res.new_record?
    # css_class << "changed" if !res.new_record?&&res.changed?
    css_class += " error" unless res.errors.empty?
    css_class
  end
  
  def changed_attributes_list(record)
    return content_tag(:div, "Record is unchanged") unless record.changed?
    attrib_list = record.changes.collect{ |attrib_name, changes| content_tag(:li, "#{attrib_name} <strong>#{changes.last}</strong> (was #{changes.first || 'empty'})") }
    content_tag(:div, content_tag(:ul, attrib_list), :class => "changed_attributes")
  end
  
  def flash_for_result(res)
    css_classes = class_for_result(res)
    return if css_classes.blank? || css_classes == "unchanged"
    "<span class='#{css_classes} flash'>#{css_classes}</span>"
  end
end
