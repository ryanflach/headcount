require_relative 'test_helper'
require_relative '../lib/statewide_test'

class StatewideTestTest < Minitest::Test
  def test_it_initializes_with_a_hash_of_test_data
    st = StatewideTest.new({:name => "Colorado"})
    assert_instance_of StatewideTest, st
  end

  def test_it_returns_its_name_upcased
    st = StatewideTest.new({:name => "Colorado"})
    assert_equal "COLORADO", st.name
  end

  def test_it_checks_grade_data_and_returns_nil_if_not_present
    st = StatewideTest.new({:name => "Colorado"})
    assert_nil st.grade_data(:third_grade)

    st.test_data[:third_grade] = {2010 => {:math => 0.333}}
    expected = {2010 => {:math => 0.333}}
    assert_equal expected, st.grade_data(:third_grade)
  end

  def test_it_checks_year_data_and_returns_nil_if_not_present
    st = StatewideTest.new({:name => "Colorado"})
    assert_nil st.year_data(:third_grade, 2010)
    assert_nil st.year_data(:asian, 2010)

    st.test_data[:third_grade] = {2010 => {:math => 0.333}}
    st.test_data[:asian] = {2010 => {:math => 0.333}}
    expected = {:math => 0.333}
    assert_equal expected, st.year_data(:third_grade, 2010)
    assert_equal expected, st.year_data(:asian, 2010)
  end

  def test_it_checks_race_data_and_returns_nil_if_not_present
    st = StatewideTest.new({:name => "Colorado"})
    assert_nil st.race_data(:asian)

    st.test_data[:asian] = {2010 => {:math => 0.333}}
    expected = {2010 => {:math => 0.333}}
    assert_equal expected, st.race_data(:asian)
  end
end
