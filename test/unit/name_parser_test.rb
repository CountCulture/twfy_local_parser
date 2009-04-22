require 'test_helper'

class NameParserTest < Test::Unit::TestCase
  OriginalNameAndParsedName = {
    "Fred Flintstone" => {:first_name => "Fred", :last_name => "Flintstone"},
    "Fred Bob Flintstone" => {:first_name => "Fred Bob", :last_name => "Flintstone"},
    "Fred-Bob Flintstone" => {:first_name => "Fred-Bob", :last_name => "Flintstone"}, 
    "Fred Flintstone-May" => {:first_name => "Fred", :last_name => "Flintstone-May"},
    "Fred Bob William Flintstone" => {:first_name => "Fred Bob William", :last_name => "Flintstone"},
    "Councillor Fred Flintstone" => {:first_name => "Fred", :last_name => "Flintstone"},
    "Mr Fred Flintstone" => {:name_title => "Mr", :first_name => "Fred", :last_name => "Flintstone"},
    "Prof Dr Fred Flintstone" => {:name_title => "Prof Dr", :first_name => "Fred", :last_name => "Flintstone"},
    "Dr Fred Flintstone" => {:name_title => "Dr", :first_name => "Fred", :last_name => "Flintstone"},
    "Dr. Fred Flintstone" => {:name_title => "Dr", :first_name => "Fred", :last_name => "Flintstone"},
    "Councillor Mrs Wilma Flintstone" => {:name_title => "Mrs", :first_name => "Wilma", :last_name => "Flintstone"},
    "Councillor Mrs. Wilma Flintstone" => {:name_title => "Mrs", :first_name => "Wilma", :last_name => "Flintstone"},
    "Professor Fred H. Flintstone" => {:name_title => "Professor", :first_name => "Fred H", :last_name => "Flintstone"},
    "Fred Flintstone BSc" => {:first_name => "Fred", :last_name => "Flintstone", :qualifications => "BSc"},
    "Fred Flintstone BSc, PhD" => {:first_name => "Fred", :last_name => "Flintstone", :qualifications => "BSc PhD"},  
    "Fred Flintstone BSc, MRTPI(Rtd)" => {:first_name => "Fred", :last_name => "Flintstone", :qualifications => "BSc"}    
    
    
    
  }
  
  context "The NameParser module" do

    should "parse first name and last name from name" do
      OriginalNameAndParsedName.each do |orig_name, parsed_values|
        assert_equal parsed_values, NameParser.parse(orig_name)
      end
    end

  end
  
end
