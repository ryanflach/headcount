require './test/test_helper'
require './lib/enrollment_repository'

class EnrollmentRepositoryTest < Minitest::Test
  def test_it_has_a_means_of_holding_District_instances
    er = EnrollmentRepository.new
    assert_equal [], er.enrollments
  end

  def test_it_can_add_instances_of_a_district_into_districts
    er = EnrollmentRepository.new
    enrollment = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {2008 => '0.30445'}})
    er.add_enrollment(enrollment)
    assert_equal [enrollment], er.enrollments
  end

end
