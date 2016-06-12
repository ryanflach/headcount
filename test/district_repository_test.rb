require_relative 'test_helper'
require_relative '../lib/district_repository'

class DistrictRepositoryTest < Minitest::Test

  def test_it_has_a_means_of_holding_District_instances
    dr = DistrictRepository.new
    expected = {}
    assert_equal expected, dr.districts
  end

  def test_it_can_be_initialized_with_districts
    district_one = District.new({:name => "Academy 20"})
    district_two = District.new({:name => "Academic University"})
    districts = {district_one.name => district_one, district_two.name => district_two}
    dr = DistrictRepository.new(districts)
    assert_equal districts, dr.districts
  end

  def test_it_can_add_instances_of_a_district_into_districts
    dr = DistrictRepository.new
    d_1 = District.new({:name => "Academy 20"})
    dr.add_district(d_1)
    expected = {d_1.name => d_1}
    assert_equal expected, dr.districts
  end

  def test_it_can_find_a_district_by_name_and_return_nil_or_the_district
    dr = DistrictRepository.new
    district_one = District.new({:name => "Academy 20"})
    dr.add_district(district_one)
    assert_equal nil, dr.find_by_name("Westminster")
    assert_equal district_one, dr.find_by_name("Academy 20")
  end

  def test_it_can_find_all_matching_districts_using_a_string_fragment
    dr = DistrictRepository.new
    d_1 = District.new({:name => "Academy 20"})
    d_2 = District.new({:name => "Academic University"})
    dr.add_district(d_1)
    dr.add_district(d_2)
    assert_equal [], dr.find_all_matching("Random")
    assert_equal [d_1, d_2], dr.find_all_matching("Acad")
  end

  def test_it_can_load_data_from_a_file_and_store_unique_Districts
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    assert_equal 181, dr.districts.count
    assert_equal 181, dr.districts.keys.uniq.count
  end

  def test_it_can_load_data_from_multiple_files_and_store_unique_Districts
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"},
                  :statewide_testing => {:math => "./test/data/Avg_prof_CSAP_TCAP_by_race_Math.csv"}})
    assert_equal 20, dr.districts.count
    assert_equal 20, dr.districts.keys.uniq.count
  end

  def test_it_can_find_enrollment_data_for_a_district_in_its_repository
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"},
                  :statewide_testing => {:math => "./test/data/Avg_prof_CSAP_TCAP_by_race_Math.csv"}})
    assert dr.find_enrollment("academy 20")
  end

  def test_it_can_find_statewide_testing_data_for_a_district_in_its_repository
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"},
                  :statewide_testing => {:math => "./test/data/Avg_prof_CSAP_TCAP_by_race_Math.csv"}})

    assert dr.find_test_data("academy 20")
  end

  def test_it_can_find_economic_profile_data_for_a_district_in_its_repository
    skip
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/data/Kinder_enroll_sample.csv"},
                  :statewide_testing => {:math => "./test/data/Avg_prof_CSAP_TCAP_by_race_Math.csv"},
                  :economic_profile => {:title_i => "./test/data/Title_I_students.csv"}})
    assert dr.find_econ_data("academy 20")
  end

end
