module NameParser

  extend self

  Titles = %w(Mr Dr Mrs Miss Professor Prof Doctor Ms)
  Qualifications = %w(BSc BA PhD DPhil)
  
  def parse(fn)
    titles, qualifications, result_hash = [], [], {}
    names = fn.sub(/Councillor|Cllr/, '').gsub(/([.,])/, '').gsub(/\([\w ]+\)/, '').gsub(/[A-Z]{3,}/, '').split(" ")
    names.delete_if{ |n| Titles.include?(n) ? titles << n : (Qualifications.include?(n) ? qualifications << n : false)}
    result_hash[:first_name] = names[0..-2].join(" ")
    result_hash[:last_name] = names.last
    result_hash[:name_title] = titles.join(" ") unless titles.empty?
    result_hash[:qualifications] = qualifications.join(" ") unless qualifications.empty?
    result_hash
  end
end