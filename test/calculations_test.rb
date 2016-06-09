require_relative 'test_helper'
require_relative '../lib/calculations'

class CalculationsTest < Minitest::Test
  include Calculations

  def test_it_can_truncate_a_float_to_three_digits
    assert_equal 0.304, truncate_float(0.304586)
  end

  def test_it_can_calculate_and_return_a_bool_if_results_greater_than_70_percent
    assert calculate_correlation([true, true, true, false])
    refute calculate_correlation([false, true, true, false])
  end

end
