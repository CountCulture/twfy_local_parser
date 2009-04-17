# attributes item_parser, title, attribute_parser

class Parser < ActiveRecord::Base
  AttribObject = Struct.new(:attrib_name, :parsing_code, :to_param)
  has_many :scrapers
  validates_presence_of :title, :item_parser
  serialize :attribute_parser
  attr_reader :results
  
  # converts the attributes we get from a new or edit form into the correct item_parser hash
  # def item_parser_attribs=(attribs)
  #   result_hash = {}
  #   attribs.each do |a|
  #     result_hash[a["name"]] = a["parser"]
  #   end
  #   self.item_parser = result_hash
  # end
  # 
  def attribute_parser_object
    return [AttribObject.new] if attribute_parser.blank?
    self.attribute_parser.collect { |k,v| AttribObject.new(k.to_s, v) }.sort{ |a,b| a.attrib_name <=> b.attrib_name }
  end
  
  def attribute_parser_object=(params)
    result_hash = {}
    params.each do |a|
      result_hash[a["attrib_name"].to_sym] = a["parsing_code"]
    end
    self.attribute_parser = result_hash
  end
  
  def process(hpricot_doc)
    @raw_response = hpricot_doc
    items = hpricot_doc.instance_eval(item_parser)
    items = [items] unless items.is_a?(Array)
    @results = items.collect do |item|
      result_hash = {}
      attribute_parser.each do |key, value|
        result_hash[key] = item.instance_eval(value)
      end
      result_hash
    end
    self
  rescue Exception => e
    message = "Exception raised (#{e.message}) by parsing code(#{item_parser})"
    errors.add_to_base(message)
    self
  end
  
end
