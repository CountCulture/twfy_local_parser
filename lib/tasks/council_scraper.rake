desc "Quick and dirty scraper to get basic info about councils from eGR page" 
task :scrape_egr_for_councils => :environment do
  BASE_URL = "http://www.brent.gov.uk"
  require 'hpricot'
  require 'open-uri'
  puts "Please enter eGR url to be scraped for councils: "
  url = $stdin.gets.chomp
  puts "Please enter global values (e.g attrib1=val1, attrib2=val2): "
  default_values = $stdin.gets.chomp
  default_hash = default_values.blank? ? {} : Hash[*default_values.split(",").collect{|ap| ap.split("=")}.flatten]
  doc = Hpricot(open(url))
  council_data = doc.search("#viewZone tr")[1..-2]
  council_data.each do |council_datum|
    council_link = council_datum.at("a[@href*='egr.nsf/LAs'")
    short_title = council_link.inner_text
    council = Council.find(:first, :conditions => ["name LIKE ?", "%#{short_title}%"]) || Council.new
    council.attributes = default_hash
    egr_url = BASE_URL + council_link[:href]
    council.authority_type ||= council_datum.search("td")[2].at("font").inner_text.strip
    council.url ||= council_datum.search("a").last.inner_text
    puts "About to scrape eGR page for #{short_title} (#{egr_url})"
    detailed_data = Hpricot(open(egr_url))
    values = detailed_data.search("#main tr")
    council.name ||= values.at("td[text()*='Full Name']").next_sibling.inner_text.strip
    council.telephone ||= values.at("td[text()*='Telephone']").next_sibling.inner_text.strip
    council.address ||= values.at("td[text()*='Address']").next_sibling.inner_text.strip
    council.ons_url ||= values.at("td[text()*='Nat Statistics']").next_sibling.at("a")[:href]
    council.wikipedia_url ||= values.at("td[text()*='Wikipedia']").next_sibling.inner_text.strip
    council.egr_id ||= values.at("td[text()*='eGR ID']").next_sibling.at("font").inner_text.strip
    begin
      council.save!
      p council.attributes, "____________"
    rescue Exception => e
      puts "Problem saving #{council.name}: #{e.message}"
    end
  end
  
end

desc "Scraper WhatDoTheyKnow.com to get WDTK name" 
task :scrape_wdtk_for_names => :environment do
  require 'hpricot'
  require 'open-uri'
  url = "http://www.whatdotheyknow.com/body/list/local_council"
  doc = Hpricot(open(url))
  wdtk_councils = doc.search("#body_list .body_listing span.head")
  Council.find(:all, :conditions => 'wdtk_name IS NULL').each do |council|
    wdtk_council = wdtk_councils.at("a[text()*='#{council.short_name}']")
    if wdtk_council
      wdtk_name = wdtk_council[:href].gsub('/body/', '')
      council.update_attribute(:wdtk_name, wdtk_name)
      puts "Added WDTK name (#{wdtk_name}) to #{council.name} record\n____________"
    else
      puts "Failed to find entry for #{council.name}"
    end
  end
  
end
