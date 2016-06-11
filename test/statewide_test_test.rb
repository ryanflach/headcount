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

  def test_it_checks_grade_year_data_and_returns_nil_if_not_present
    st = StatewideTest.new({:name => "Colorado"})
    assert_nil st.grade_year_data(:third_grade, 2010)
    st.test_data[:third_grade] = {2010 => {:math => 0.333}}

    expected = {:math => 0.333}
    assert_equal expected, st.grade_year_data(:third_grade, 2010)
  end

  def test_it_checks_race_year_data_and_returns_nil_if_not_present
    st = StatewideTest.new({:name => "Colorado"})
    assert_nil st.race_year_data(:asian, 2010)
    st.test_data[:asian] = {2010 => {:math => 0.333}}

    expected = {:math => 0.333}
    assert_equal expected, st.race_year_data(:asian, 2010)
  end

  def test_it_checks_race_data_and_returns_nil_if_not_present
    st = StatewideTest.new({:name => "Colorado"})
    assert_nil st.race_data(:asian)

    st.test_data[:asian] = {2010 => {:math => 0.333}}
    expected = {2010 => {:math => 0.333}}
    assert_equal expected, st.race_data(:asian)
  end

  def test_it_raises_an_unknown_data_error_if_proficient_by_grade_arg_is_not_3_or_8
    st = StatewideTest.new({:name => "Colorado"})
    assert_raises(UnknownDataError) do
      st.proficient_by_grade(4)
    end
  end

  def test_it_can_return_grade_data_by_chosen_grade_year
    st = StatewideTest.new({:name => "Academy 20", :third_grade => {2010 => {:math => 0.333}}})
    expected = {2010 => {:math => 0.333}}
    assert_equal expected, st.proficient_by_grade(3)
  end

  def test_it_can_return_grade_data_sorted_and_truncated_by_chosen_grade_year
    st = StatewideTest.new({:name => "Academy 20",
                            :eighth_grade => {2010 => {:math => 0.333, :reading => 0.333344, :writing => 0.55544},
                                             2008 => {:math => 0.5466, :reading => 0.44225, :writing => 0.77355}}})
    expected = {2008 => {:math => 0.546, :reading => 0.442, :writing => 0.773},
                2010 => {:math => 0.333, :reading => 0.333, :writing => 0.555}}
    assert_equal expected, st.proficient_by_grade(8)
  end

  def test_it_raises_an_unknown_race_error_if_unknown_race_is_requests
    st = StatewideTest.new({:name => "Colorado"})
    assert_raises(UnknownRaceError) do
      st.proficient_by_race_or_ethnicity(:hawaiian)
    end
  end

  def test_it_can_return_race_data_sorted_and_truncated_by_chosen_race
    st = StatewideTest.new({:name => "Academy 20",
                            :asian => {2010 => {:math => 0.333, :reading => 0.333344, :writing => 0.55544},
                                       2008 => {:math => 0.5466, :reading => 0.44225, :writing => 0.77355}}})
    expected = {2008 => {:math => 0.546, :reading => 0.442, :writing => 0.773},
                2010 => {:math => 0.333, :reading => 0.333, :writing => 0.555}}
    assert_equal expected, st.proficient_by_race_or_ethnicity(:asian)
  end

  def test_it_raises_unknown_data_error_if_subject_grade_or_year_is_not_available
    st = StatewideTest.new({:name => "Academy 20",
                            :eighth_grade => {2010 => {:math => 0.333, :reading => 0.333344, :writing => 0.55544},
                                             2008 => {:math => 0.5466, :reading => 0.44225, :writing => 0.77355}}})
    assert_raises(UnknownDataError) do
      st.proficient_for_subject_by_grade_in_year(:math, 3, 2008)
    end

    assert_raises(UnknownDataError) do
      st.proficient_for_subject_by_grade_in_year(:science, 8, 2008)
    end

    assert_raises(UnknownDataError) do
      st.proficient_for_subject_by_grade_in_year(:math, 8, 2015)
    end
  end

  def test_it_can_return_truncated_percentage_given_subject_year_and_grade_level
    st = StatewideTest.new({:name => "Academy 20",
                            :eighth_grade => {2010 => {:math => 0.333, :reading => 0.333344, :writing => 0.55544},
                                             2008 => {:math => 0.5466, :reading => 0.44225, :writing => 0.77355}}})
    assert_equal 0.546, st.proficient_for_subject_by_grade_in_year(:math, 8, 2008)
  end

  def test_it_raises_an_unknown_data_error_if_subject_race_or_year_data_is_unavailable
    st = StatewideTest.new({:name => "Academy 20",
                            :black => {2010 => {:math => 0.333, :reading => 0.333344, :writing => 0.55544},
                                       2008 => {:math => 0.5466, :reading => 0.44225, :writing => 0.77355}}})
    assert_raises(UnknownDataError) do
      st.proficient_for_subject_by_race_in_year(:math, :asian, 2008)
    end

    assert_raises(UnknownDataError) do
      st.proficient_for_subject_by_race_in_year(:science, :black, 2008)
    end

    assert_raises(UnknownDataError) do
      st.proficient_for_subject_by_race_in_year(:math, :black, 2015)
    end
  end

  def test_it_can_return_truncated_percentage_given_subject_year_and_race
    st = StatewideTest.new({:name => "Academy 20",
                            :black => {2010 => {:math => 0.333, :reading => 0.333344, :writing => 0.55544},
                                       2008 => {:math => 0.5466, :reading => 0.44225, :writing => 0.77355}}})
    assert_equal 0.546, st.proficient_for_subject_by_race_in_year(:math, :black, 2008)
  end

end
