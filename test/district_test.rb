require_relative 'test_helper'
require_relative '../lib/district'

class DistrictTest < Minitest::Test

  def test_it_stores_the_name_of_the_district
    district = District.new({:name => "ACADEMY 20"})
    assert_equal "ACADEMY 20", district.name
  end

  def test_it_stores_the_name_upcased
    district = District.new({:name => "Academy 20"})
    assert_equal "ACADEMY 20", district.name
  end

end
