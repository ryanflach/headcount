require_relative 'test_helper'
require_relative '../lib/enrollment'

class EnrollmentTest < Minitest::Test

  def test_it_can_access_the_name_of_stored_districts
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2007 => '.304586'}})
    assert_equal "ACADEMY 20", enrollment.name
  end

  def test_it_stores_the_name_upcased
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2007 => '.304586'}})
    assert_equal "ACADEMY 20", enrollment.name
  end

  def test_it_can_return_participation_data_by_year_with_percent_truncated
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2007 => '.304586'}})
    assert_equal ({2007=>0.304}), enrollment.kindergarten_participation_by_year

    enrollment = Enrollment.new({:name => "ACADEMY 20", :high_school_graduation => {2007 => '.304586'}})
    assert_equal ({2007=>0.304}), enrollment.graduation_rate_by_year
  end

  def test_it_can_return_participation_data_by_year_sorted_by_year
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal ({2007=>0.304, 2008=>0.397, 2009=>0.407}), enrollment.kindergarten_participation_by_year

    enrollment = Enrollment.new({:name => "ACADEMY 20", :high_school_graduation => {2007 => '.304586'}})
    assert_equal ({2007=>0.304}), enrollment.graduation_rate_by_year
  end

  def test_it_can_return_participation_for_a_chosen_year
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal 0.397, enrollment.kindergarten_participation_in_year(2008)

    enrollment = Enrollment.new({:name => "ACADEMY 20", :high_school_graduation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal 0.397, enrollment.graduation_rate_in_year(2008)
  end

  def test_participation_in_year_returns_nil_if_no_data_for_that_year
    enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal nil, enrollment.kindergarten_participation_in_year(2015)

    enrollment = Enrollment.new({:name => "ACADEMY 20", :high_school_graduation => {2008 => '.39784', 2009 => '.40756', 2007 => '.304586'}})
    assert_equal nil, enrollment.graduation_rate_in_year(2015)
  end

end
