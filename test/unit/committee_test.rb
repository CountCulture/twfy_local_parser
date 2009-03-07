require 'test_helper'

class CommitteeTest < ActiveSupport::TestCase
  
  should_validate_presence_of :title, :url
  
  context "A Committee instance" do
    setup do
      @committee = Committee.new(:title => "Some Committee", :url => "some.url")
    end
    
    # should "return full name" do
    #   assert_equal "Bob Williams", @member.full_name
    # end
  end
  
  private
  def new_committee(options={})
    Committee.new({:title => "Some Title"}.merge(options))
  end
end
