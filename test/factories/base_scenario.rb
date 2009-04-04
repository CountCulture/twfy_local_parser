Factory.define :scraper do |s|
  s.url 'http://www.anytown.gov.uk/members/bob'
  s.result_model 'Member' 
  s.expected_result_attributes ":foo => \"bar\""
  s.association :parser
  s.association :council
end
Factory.define :scraper_with_errors, :parent => :scraper do |s|
  s.result_model 'Committee'
end
Factory.define :scraper_with_results, :parent => :scraper do |s|
  s.results  {"some results"}
  s.association :parser, :factory => :another_parser
  s.association :council, :factory => :tricky_council
end


Factory.define :parser do |f|
  f.title 'dummy parser'
  f.parsing_code  'some code'
end
Factory.define :another_parser, :parent => :parser do |f|
  f.title 'another dummy parser'
end

Factory.define :council do |f|
  f.name 'Anytown'
  f.url 'http://www.anytown.gov.uk'
end
Factory.define :tricky_council, :class => :council do |f|
  f.name 'Another Town'
  f.url 'http://www.anothertown.gov.uk'
end