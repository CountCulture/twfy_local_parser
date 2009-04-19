module ScrapersHelper
  def class_for_result(res)
    css_class = []
    css_class << "new" if res.new_record?
    css_class << "error" unless res.errors.empty?
    css_class << "changed" if !res.new_record?&&res.changed?
    css_class.join(" ")
  end
  
  def flash_for_result(res)
    css_classes = class_for_result(res)
    return if css_classes.blank?
    "<span class='#{css_classes} flash'>#{css_classes}</span>"
  end
end
