require_relative 'test_helper'
require_relative '../lib/calculations'

class CalculationsTest < Minitest::Test
  include Calculations

  def test_it_can_truncate_a_float_to_three_digits
    assert_equal 0.304, truncate_float(0.304586)
  end

end
