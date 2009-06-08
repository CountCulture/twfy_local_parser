# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_for(obj=nil, options={})
    link_to(h(obj.title), obj, options) unless obj.blank?
  end
  
  def link_to_api_url(response_type)
    link_to(response_type, params.merge(:format => response_type), :class => "api_link")
  end
end
