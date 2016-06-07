require './test/test_helper'
require './lib/enrollment_repository'

class EnrollmentRepositoryTest < Minitest::Test

  def test_it_has_a_means_of_holding_District_instances
    er = EnrollmentRepository.new
    expected = {}
    assert_equal expected, er.enrollments
  end

  def test_it_can_add_instances_of_an_enrollment_into_enrollments
    er = EnrollmentRepository.new
    enrollment = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {2008 => '0.30445'}})
    er.add_enrollment(enrollment)
    expected = {enrollment.name => enrollment}
    assert_equal expected, er.enrollments
  end

  def test_it_can_find_enrollment_by_case_insensitive_name
    enrollment = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {2008 => '0.30445'}})
    er = EnrollmentRepository.new({enrollment.name => enrollment})
    assert_equal enrollment, er.find_by_name("AcAdeMY 20")
  end

  def test_find_by_name_returns_nil_if_not_found
    enrollment = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {2008 => '0.30445'}})
    er = EnrollmentRepository.new({enrollment.name => enrollment})
    assert_equal nil, er.find_by_name("Pizza Academy")
  end

  def test_it_can_load_data_from_file_and_create_and_store_enrollments
    er = EnrollmentRepository.new
    er.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv"
        }
      })
    enrollment = er.find_by_name("ACADEMY 20")
    assert_equal "ACADEMY 20", enrollment.name
  end

end
