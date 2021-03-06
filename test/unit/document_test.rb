require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  
  context "The Document class" do
    setup do
      @document = Factory(:document)
    end
    
    should_validate_presence_of :body, :url
    should_validate_uniqueness_of :url
    should_belong_to :document_owner
    should_have_db_column :raw_body
  end
  
  context "A Document instance" do
    
    context "in general" do
      setup do
        @committee = Factory(:committee)
        @council = @committee.council
        @doc_owner = Factory(:meeting, :council => @committee.council, :committee => @committee)
        @document = Factory(:document, :document_owner => @doc_owner)
      end
      
      should "return document type and document owner as title" do
        @document.stubs(:document_type).returns("FooDocument")
        assert_equal "FooDocument for #{@doc_owner.title}", @document.title
      end
      
      should "return title attribute if set" do
        @document.title = "new title"
        assert_equal "new title", @document.title
      end
      
      should "return 'Document' as document_type if not set" do
        assert_equal "Document", @document.document_type
      end
      
      should "return document_type if set" do
        @document.document_type = "Minutes"
        assert_equal "Minutes", @document.document_type
      end
    end
    
    context "when setting body" do
      setup do
        @document = Document.new
      end

      should "store raw text in raw_body" do
        assert_equal "raw <font='Helvetica'>text</font>", Document.new(:body => "raw <font='Helvetica'>text</font>").raw_body
      end
      
      should "sanitize raw text" do
        @document.expects(:sanitize_body).with("raw <font='Helvetica'>text</font>")
        @document.body = "raw <font='Helvetica'>text</font>"
      end
      
      should "store sanitized text in body" do
        @document.stubs(:sanitize_body).returns("sanitized text")
        @document.body = "raw text"
        assert_equal "sanitized text", @document.body
      end
      
      should "not raise exception when setting body to nil" do
        assert_nothing_raised(Exception) { @document.body = nil }
      end
    end
    
    context "when sanitizing body text" do
      setup do
        @raw_text = "some <font='Helvetica'>stylized text</font> with <a href='councillor22'>relative link</a> and an <a href='http://external.com/dummy'>absolute link</a>. Also <script> something dodgy</script> here"
        @document = Document.new(:url => "http://www.council.gov.uk/document/some_page.htm?q=something")
      end
      
      should "convert relative urls to absolute ones based on url" do
        assert_match /with <a href="http:\/\/www\.council\.gov\.uk\/document\/councillor22/, @document.send(:sanitize_body, @raw_text)
      end
      
      should "not change urls of absolute links" do
        assert_match /an <a href=\"http:\/\/external\.com\/dummy\"/, @document.send(:sanitize_body, @raw_text)
      end
      
      should "add external class to all links" do
        assert_match /councillor22\" class=\"external/, @document.send(:sanitize_body, @raw_text)
        assert_match /dummy\" class=\"external/, @document.send(:sanitize_body, @raw_text)
      end
      
      should "remove images" do
        assert_match /with  image/, @document.send(:sanitize_body, "text with <img src='http://council.gov.uk/image' /> image")
      end
    end
    
    # should "delegate council to document_owner" do
    #   assert_equal @doc_owner.council, @document.council
    # end
  end
end
