require_relative 'test_helper'
require_relative '../lib/headcount_analyst'
require_relative '../lib/district_repository'

class HeadcountAnalystTest < Minitest::Test

  def test_it_initializes_with_a_district_repository
    dr = DistrictRepository.new
    ha = HeadcountAnalyst.new(dr)
    assert_equal dr, ha.district_repo
  end

  def test_if_no_argument_is_passed_in_it_defaults_to_nil
    ha = HeadcountAnalyst.new
    assert_nil ha.district_repo
  end

  def test_it_can_find_the_average_from_a_hash_of_data
    ha = HeadcountAnalyst.new
    hash = {2008 => 0.39784, 2009 => 0.40756, 2007 => 0.304586}
    expected = 0.3699953333333334
    assert_equal expected, ha.find_average(hash)
  end

  def test_it_can_find_average_between_two_sets_of_data
    dr  = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = 0.819
    assert_equal expected, ha.kindergarten_participation_rate_variation("ADAMS COUNTY 14", :against => "COLORADO")
  end

  def test_it_can_compare_data_on_a_yearly_basis
    dr  = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = {2006 => 0.870, 2007 => 0.776}
    assert_equal expected, ha.kindergarten_participation_rate_variation_trend("ADAMS COUNTY 14", :against => "COLORADO")
  end

  def test_it_can_find_and_return_kindergarten_enrollment_data_for_a_district
    dr  = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = {2006 => 0.29331, 2007 => 0.30643}
    assert_equal expected, ha.district_kindergarten_enrollment_data('adams county 14')
  end

  def test_it_can_find_and_return_as_a_hash_requested_district_and_comparison_kindergarten_enrollment_data
    dr  = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = {:district => {2006 => 0.29331, 2007 => 0.30643}, :comparison => {2006 => 0.33677, 2007 => 0.39465}}
    assert_equal expected, ha.kindergarten_district_and_comparison_data('adams county 14', :against => 'colorado')
  end

end
