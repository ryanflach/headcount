require './test/test_helper'
require './lib/enrollment_repository'

class EnrollmentRepositoryTest < Minitest::Test
  def test_it_has_a_means_of_holding_District_instances
    skip
    er = EnrollmentRepository.new
    assert_equal [], er.enrollments
  end

  def test_it_can_add_instances_of_a_district_into_districts
    skip
    er = EnrollmentRepository.new
    district_one = District.new({:name => "Academy 20"})
    er.add_district(district_one)
    assert_equal [district_one], er.districts
  end

  def test_it_can_find_a_district_by_name_and_return_nil_or_the_district
    skip
    er = EnrollmentRepository.new
    district_one = District.new({:name => "Academy 20"})
    er.add_district(district_one)
    assert_equal nil, er.find_by_name("Westminster")
    assert_equal district_one, er.find_by_name("Academy 20")
  end
end
