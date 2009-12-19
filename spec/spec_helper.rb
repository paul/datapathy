require 'rubygems'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'datapathy'

require 'pp'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

module Helpers
  require 'uuidtools'
  def new_uuid
    UUIDTools::UUID.random_create.to_s
  end

  def test_adapter
    Datapathy.default_adapter
  end
end

Spec::Runner.configure do |config|

  config.include(Helpers)
  config.include(Matchers)

end
