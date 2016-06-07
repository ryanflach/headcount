require './test/test_helper'
require './lib/enrollment'

class EnrollmentTest < Minitest::Test
  def test_it_stores_the_name_of_the_district
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2007 => '.304586'}})
    assert_equal "ACADEMY 20", enrollment.name
  end

  def test_it_stores_the_name_upcased
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2007 => '.304586'}})
    assert_equal "ACADEMY 20", enrollment.name
  end

  def test_it_stores_the_kindergarten_participation_in_a_hash
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2007 => '.304586'}})
    assert_equal ({2007=>".304586"}), enrollment.kindergarten_participation
  end

  def test_it_can_return_the_kindergarten_participation_by_year_with_percent_truncated
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2007 => '.304586'}})
    assert_equal ({2007=>0.305}), enrollment.kindergarten_participation_by_year
  end

  def test_it_can_return_kindergarten_participation_by_year_sorted_by_year
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal ({2007=>0.305, 2008=>0.398, 2009=>0.408}), enrollment.kindergarten_participation_by_year
  end

  def test_it_can_return_kindergarten_participation_for_a_chosen_year
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal 0.398, enrollment.kindergarten_participation_in_year(2008)
  end

  def test_kindergarten_participation_in_year_returns_nil_if_no_data_for_that_year
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal nil, enrollment.kindergarten_participation_in_year(2015)
  end

end
