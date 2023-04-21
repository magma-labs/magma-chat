require 'simplecov'

SimpleCov.start 'rails' do
  add_group 'Services', 'app/services'
  add_group 'Reflexes', 'app/reflexes'
  add_group 'Constraints', 'app/constraints'
end
