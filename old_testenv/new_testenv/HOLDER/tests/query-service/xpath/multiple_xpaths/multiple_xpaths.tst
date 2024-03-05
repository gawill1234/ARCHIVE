echo "Testing Multiple XPaths including <"
rspec -c less_than_spec.rb
echo "-----------------------------------"

echo "Testing Multiple XPaths including <="
rspec -c less_than_or_equal_spec.rb
echo "-----------------------------------"

echo "Testing Multiple XPaths including =="
rspec -c equal_spec.rb
echo "-----------------------------------"

echo "Testing Multiple XPaths including >"
rspec -c greater_than_spec.rb
echo "-----------------------------------"

echo "Testing Multiple XPaths including >="
rspec -c greater_than_or_equal_spec.rb
echo "-----------------------------------"

