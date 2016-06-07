require './test/test_helper'
require './lib/district_repository'

class DistrictRepositoryTest < Minitest::Test

  def test_it_has_a_means_of_holding_District_instances
    dr = DistrictRepository.new
    assert_equal [], dr.districts
  end

  def test_it_can_be_initialized_with_districts
    district_one = District.new({:name => "Academy 20"})
    district_two = District.new({:name => "Academic University"})
    dr = DistrictRepository.new([district_one, district_two])
    assert_equal [district_one, district_two], dr.districts
  end

  def test_it_can_add_instances_of_a_district_into_districts
    dr = DistrictRepository.new
    district_one = District.new({:name => "Academy 20"})
    dr.add_district(district_one)
    assert_equal [district_one], dr.districts
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
    district_one = District.new({:name => "Academy 20"})
    district_two = District.new({:name => "Academic University"})
    dr.add_district(district_one)
    dr.add_district(district_two)
    assert_equal [], dr.find_all_matching("Random")
    assert_equal [district_one, district_two], dr.find_all_matching("Acad")
  end

  def test_it_can_load_data_from_a_file_and_store_Districts
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    assert_equal 1991, dr.districts.count
  end

end
