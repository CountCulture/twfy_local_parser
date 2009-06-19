class Document < ActiveRecord::Base
  validates_presence_of :body
  validates_presence_of :url
  validates_uniqueness_of :url
  belongs_to :document_owner, :polymorphic => true
    
  def body=(raw_text)
    self[:raw_body] = raw_text # save orig raw text
    write_attribute(:body, sanitize_body(raw_text))#self[:body] = sanitize_body(raw_text)
  end
  
  protected
  def sanitize_body(raw_text)
    return if raw_text.blank?
    sanitized_body = ActionController::Base.helpers.sanitize(raw_text)
    base_url = url&&url.sub(/\/[^\/]+$/,'/')
    doc = Hpricot(sanitized_body)
    doc.search("a[@href]").each do |link|
      link[:href].match(/^http:/) ? link : link.set_attribute(:href, "#{base_url}#{link[:href]}")
      link.set_attribute(:class, 'external')
    end
    doc.to_html
  end
end
