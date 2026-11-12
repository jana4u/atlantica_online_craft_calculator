require 'simplecov'
SimpleCov.start do
  skip '/test/'
end

require 'minitest/autorun'

class Minitest::Test
  alias_method :assert_not_nil, :refute_nil
end
