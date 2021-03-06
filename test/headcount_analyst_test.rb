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

  def test_if_there_is_a_correlation_between_HS_graduation_and_kindergarten_enrollment
    dr  = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv",
                                  :high_school_graduation => "./test/data/HS_grad_sample.csv"}})
    ha = HeadcountAnalyst.new(dr)
    assert ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
  end

  def test_it_returns_boolean_for_kindergarten_HS_correlation_statewide
    dr  = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv",
                                  :high_school_graduation => "./test/data/HS_grad_sample.csv"}})
    ha = HeadcountAnalyst.new(dr)
    refute ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'STATEWIDE')
  end

  def test_it_returns_boolean_ratio_for_kinder_HS_correlation_across_multiple_districts
    dr  = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv",
                                  :high_school_graduation => "./test/data/HS_grad_sample.csv"}})
    ha = HeadcountAnalyst.new(dr)
    multi_districts = ['ADAMS COUNTY 14', 'YUMA SCHOOL DISTRICT 1', 'ACADEMY 20']
    refute ha.kindergarten_participation_correlates_with_high_school_graduation(across: multi_districts)
  end

  def test_it_raises_an_error_if_a_grade_key_is_not_provided
    ha = HeadcountAnalyst.new()
    assert_raises(InsufficientInformationError) do
      ha.top_statewide_test_year_over_year_growth(subject: :math)
    end
  end

  def test_it_raises_an_error_if_a_grade_value_is_not_3_or_8
    ha = HeadcountAnalyst.new()
    assert_raises(UnknownDataError) do
      ha.top_statewide_test_year_over_year_growth(grade: 9)
    end
  end

  def test_it_can_find_district_with_top_percentage_growth
    dr  = DistrictRepository.new
    dr.load_data({:statewide_testing => {:third_grade => "./test/data/3rd_grade_prof_CSAP_TCAP.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = ["SANGRE DE CRISTO RE-22J", 0.071]
    assert_equal expected, ha.top_statewide_test_year_over_year_growth({:grade => 3, :subject => :math})
  end

  def test_it_can_find_multiple_districts_of_growth
    dr  = DistrictRepository.new
    dr.load_data({:statewide_testing => {:third_grade => "./test/data/3rd_grade_prof_CSAP_TCAP.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = [["SANGRE DE CRISTO RE-22J", 0.071], ["CENTENNIAL R-1", 0.036]]
    assert_equal expected, ha.top_statewide_test_year_over_year_growth({:grade => 3, :top => 2, :subject => :math})
  end

  def test_it_can_compare_growth_across_all_subjects
    dr  = DistrictRepository.new
    dr.load_data({:statewide_testing => {:third_grade => "./test/data/3rd_grade_prof_CSAP_TCAP.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = ["SANGRE DE CRISTO RE-22J", 0.071]
    assert_equal expected, ha.top_statewide_test_year_over_year_growth(grade: 3)
  end

  def test_it_raises_an_error_if_weighting_is_provided_but_does_not_add_to_1
    ha = HeadcountAnalyst.new
    assert_raises(InsufficientInformationError) do
      ha.weighting_check({:weighting => {:math => 0.4, :reading => 0.5, :writing => 0.0}})
    end
  end

  def test_it_can_take_weight_arguments_and_return_weighted_results
    dr  = DistrictRepository.new
    dr.load_data({:statewide_testing => {:third_grade => "./test/data/3rd_grade_prof_CSAP_TCAP.csv"}})
    ha = HeadcountAnalyst.new(dr)
    expected = ["CENTENNIAL R-1", 0.075]
    assert_equal expected, ha.top_statewide_test_year_over_year_growth(grade: 3, weighting: {math: 0.5, reading: 0.5, writing: 0.0})
  end

end
