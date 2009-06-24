module ScrapersHelper
  def class_for_result(res)
    css_class = 
      case 
      when res.new_record? || res.new_record_before_save?
        "new"
      when res.changed?
        "changed"
      else
        "unchanged"
      end
    css_class += " error" unless res.errors.empty?
    css_class
  end
  
  def changed_attributes_list(record)
    return content_tag(:div, "Record is unchanged") unless record.changed? || record.new_record_before_save?
    attrib_list = record.changes.collect{ |attrib_name, changes| content_tag(:li, "#{attrib_name} <strong>#{changes.last}</strong> (was #{changes.first || 'empty'})") }
    content_tag(:div, content_tag(:ul, attrib_list), :class => "changed_attributes")
  end
  
  def flash_for_result(res)
    css_classes = class_for_result(res)
    return if css_classes.blank? || css_classes == "unchanged"
    "<span class='#{css_classes} flash'>#{css_classes}</span>"
  end
  
  def scraper_links_for_council(council)
    existing_scraper_links, new_scraper_links = [], []
    scrapers = council.scrapers
    
    Parser::ALLOWED_RESULT_CLASSES.each do |r|
      Scraper::SCRAPER_TYPES.each do |st|
        if es = scrapers.detect{ |s| s.type == st && s.result_model == r }
          css_classes = [] << (es.problematic? ? "problem" : nil )
          css_classes << (es.stale? ? "stale" : nil )
          css_classes = css_classes.compact.blank? ? nil : css_classes.compact.join(" ")
          existing_scraper_links << link_for(es, :class => css_classes)
        else
          new_scraper_links << link_to("Add #{r} #{st.sub('Scraper', '').downcase} scraper for #{council.name} council", new_scraper_path(:council_id => council.id, :result_model => r, :type => st), :class => "new_scraper_link")
        end
      end
    end
    existing_scraper_links + new_scraper_links
  end
end
