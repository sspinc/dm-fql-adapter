require 'dm-core'
require 'dm-types'

require 'dm-fql-adapter/spec/setup'

# Requires test resources in ./resources/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/resources/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
end
