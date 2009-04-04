module AcceptsNestedAttributesForMacros
  def should_accept_nested_attributes_for(*attr_names)
    klass = self.name.gsub(/Test$/, '').constantize
 
    context "#{klass}" do
      attr_names.each do |association_name|
        should "accept nested attrs for #{association_name}" do
          assert  klass.instance_methods.include?("#{association_name}_attributes="),
                  "#{klass} does not accept nested attributes for #{association_name}"
        end
      end
    end
  end
end
 
class ActiveSupport::TestCase
  extend AcceptsNestedAttributesForMacros
end