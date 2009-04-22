# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_for(obj=nil)
    link_to(h(obj.title), obj) unless obj.blank?
  end
end
