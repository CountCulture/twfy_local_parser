# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def council_page_for(obj)
    link_to("council page", obj.url, :class => "council_page_link external")
  end
  
  def link_for(obj=nil, options={})
    css_class = ["#{obj.class.to_s.downcase}_link", options.delete(:class)].compact.join(" ")
    link_to(h(obj.title), obj, { :class => css_class }.merge(options)) unless obj.blank?
  end
  
  def link_to_api_url(response_type)
    link_to(response_type, params.merge(:format => response_type), :class => "api_link")
  end
  
  def list_all(coll=nil)
    if coll.blank?
      "<p class='no_results'>No results</p>"
    else
      coll = coll.is_a?(Array) ? coll : [coll]
      content_tag(:ul, coll.collect{ |i| (content_tag(:li, link_for(i))) }.join)
    end
  end
end
