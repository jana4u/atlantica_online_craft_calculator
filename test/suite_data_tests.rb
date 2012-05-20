require 'test/unit'

Dir[File.join(File.dirname(__FILE__), 'data_test_*.rb')].each do |file|
  require file
end
