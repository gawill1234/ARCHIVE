echo "Running all xpath operator tests"
echo "================================"

rspec -c close_by_numbers_spec.rb date_comparisons_spec.rb date_range_spec.rb hard_to_express_numbers_spec.rb maximal_numbers_spec.rb equal_spec.rb greater_than_or_equal_spec.rb greater_than_spec.rb less_than_or_equal_spec.rb less_than_spec.rb numeric_comparisons_spec.rb numeric_not_spec.rb numeric_range_spec.rb simple_form_spec.rb string_equality_spec.rb string_not_spec.rb wrong_types_spec.rb
status=$?

if [ $status -eq 0 ]; then
   delete_collection -C xpath-operator-testing
   delete_collection -C test-xpath-operator2
   echo "xpath_combined: Test Passed"
else
   echo "xpath_combined:  Test Failed"
   stop_indexing -C xpath-operator-testing
   stop_indexing -C test-xpath-operator2
fi

exit ${status}
