require_relative 'test_helper'
require_relative '../lib/statewide_test_repository'

class StatewideTestRepositoryTest < Minitest::Test
  def test_it_initializes_with_an_empty_hash_by_default
    str = StatewideTestRepository.new
    expected = {}
    assert_equal expected, str.tests
  end

  def test_it_can_add_test_data_and_store_statewide_test_objects
    str = StatewideTestRepository.new
    st = StatewideTest.new(:name => "Colorado")
    str.add_testing_data(st)

    expected = {"COLORADO" => st}
    assert_equal expected, str.tests
  end

  def test_it_can_find_statewide_test_objects_by_name
    str = StatewideTestRepository.new
    st = StatewideTest.new(:name => "Colorado")
    str.add_testing_data(st)

    expected = st
    assert_equal expected, str.find_by_name("Colorado")
  end

  def test_it_can_check_if_a_statewide_test_object_has_grade_data
    str = StatewideTestRepository.new
    st = StatewideTest.new(:name => "Colorado")
    str.add_testing_data(st)

    refute str.has_grade(st, :third_grade)

    st.test_data[:third_grade] = {2010 => {:math => 0.333}}
    assert str.has_grade(st, :third_grade)
  end

  def test_it_can_check_if_a_statewide_test_object_has_data_for_a_given_year
    str = StatewideTestRepository.new
    st = StatewideTest.new(:name => "Colorado")
    str.add_testing_data(st)

    refute str.has_year(st, :third_grade, 2010)

    st.test_data[:third_grade] = {2010 => {:math => 0.333}}
    assert str.has_year(st, :third_grade, 2010)
  end

  def test_it_can_check_if_a_statwide_test_object_has_grade_and_given_year
    str = StatewideTestRepository.new
    st = StatewideTest.new(:name => "Colorado", :third_grade => {2010 => {:math => 0.333}})
    str.add_testing_data(st)

    refute str.has_grade_and_year(st, :third_grade, 2011)
    assert str.has_grade_and_year(st, :third_grade, 2010)
  end

  def test_it_can_add_grade_data_to_its_repository_when_object_is_new
    str = StatewideTestRepository.new
    existing = nil
    data = {:name => "Colorado", :grade => :third_grade, :year => 2010, :subject => :math, :percent => 0.333}
    str.add_grade_data(data, existing)

    expected = {2010 => {:math => 0.333}}
    assert_equal expected, str.find_by_name('colorado').grade_data(:third_grade)
  end

  def test_it_can_add_grade_data_to_its_repository_when_only_name_exists
    str = StatewideTestRepository.new
    st = StatewideTest.new({:name => "Colorado"})
    str.add_testing_data(st)
    existing = st
    data = {:name => "Colorado", :grade => :third_grade, :year => 2011, :subject => :math, :percent => 0.465}
    str.add_grade_data(data, existing)

    expected = {2011 => {:math => 0.465}}
    assert_equal expected, str.find_by_name('colorado').grade_data(:third_grade)
  end

  def test_it_can_add_grade_data_to_its_repository_when_object_grade_exists
    str = StatewideTestRepository.new
    st = StatewideTest.new({:name => "Colorado", :third_grade => {2010 => {:math => 0.333}}})
    str.add_testing_data(st)
    existing = st
    data = {:name => "Colorado", :grade => :third_grade, :year => 2011, :subject => :math, :percent => 0.465}
    str.add_grade_data(data, existing)

    expected = {2010 => {:math => 0.333}, 2011 => {:math => 0.465}}
    assert_equal expected, str.find_by_name('colorado').grade_data(:third_grade)
  end

  def test_it_can_add_grade_data_to_its_repository_when_object_grade_and_year_exists
    str = StatewideTestRepository.new
    st = StatewideTest.new({:name => "Colorado", :third_grade => {2010 => {:math => 0.333}}})
    str.add_testing_data(st)
    existing = st
    data = {:name => "Colorado", :grade => :third_grade, :year => 2010, :subject => :reading, :percent => 0.465}
    str.add_grade_data(data, existing)

    expected = {2010 => {:math => 0.333, :reading => 0.465}}
    assert_equal expected, str.find_by_name('colorado').grade_data(:third_grade)
  end

  def test_it_can_if_a_statewide_object_has_race_data
    str = StatewideTestRepository.new
    st = StatewideTest.new(:name => "Colorado")
    str.add_testing_data(st)

    refute str.has_race(st, :asian)

    st.test_data[:asian] = {2010 => {:math => 0.333}}
    assert str.has_race(st, :asian)
  end

  def test_it_can_check_if_a_statewide_object_has_race_data_for_a_given_year
    str = StatewideTestRepository.new
    st = StatewideTest.new(:name => "Colorado", :asian => {2010 => {:math => 0.333}})
    str.add_testing_data(st)

    refute str.has_grade_and_year(st, :asian, 2011)
    assert str.has_grade_and_year(st, :asian, 2010)
  end

  def test_it_can_add_testing_data_to_its_repository_when_object_is_new
    str = StatewideTestRepository.new
    existing = nil
    data = {:name => "Colorado", :race => :asian, :year => 2010, :subject => :math, :percent => 0.333}
    str.add_test_results(data, existing)

    expected = {2010 => {:math => 0.333}}
    assert_equal expected, str.find_by_name('colorado').race_data(:asian)
  end

  def test_it_can_add_testing_data_to_its_repository_when_only_name_exists
    str = StatewideTestRepository.new
    st = StatewideTest.new({:name => "Colorado"})
    str.add_testing_data(st)
    existing = st
    data = {:name => "Colorado", :race => :white, :year => 2011, :subject => :math, :percent => 0.465}
    str.add_test_results(data, existing)

    expected = {2011 => {:math => 0.465}}
    assert_equal expected, str.find_by_name('colorado').race_data(:white)
  end

  def test_it_can_add_testing_data_to_its_repository_when_object_race_exists
    str = StatewideTestRepository.new
    st = StatewideTest.new({:name => "Colorado", :asian => {2010 => {:math => 0.333}}})
    str.add_testing_data(st)
    existing = st
    data = {:name => "Colorado", :race => :asian, :year => 2011, :subject => :math, :percent => 0.465}
    str.add_test_results(data, existing)

    expected = {2010 => {:math => 0.333}, 2011 => {:math => 0.465}}
    assert_equal expected, str.find_by_name('colorado').race_data(:asian)
  end

  def test_it_can_add_testing_data_to_its_repository_when_object_race_and_year_exists
    str = StatewideTestRepository.new
    st = StatewideTest.new({:name => "Colorado", :asian => {2010 => {:math => 0.333}}})
    str.add_testing_data(st)
    existing = st
    data = {:name => "Colorado", :race => :asian, :year => 2010, :subject => :reading, :percent => 0.465}
    str.add_test_results(data, existing)

    expected = {2010 => {:math => 0.333, :reading => 0.465}}
    assert_equal expected, str.find_by_name('colorado').race_data(:asian)
  end

  def test_it_can_load_and_add_grade_data_from_a_file
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {:third_grade => "./test/data/3rd_grade_prof_CSAP_TCAP.csv"}})
    expected = {2010 => {:reading => 0.0}, 2008 => {:writing => 0.0}}
    assert_equal expected, str.find_by_name('platte valley re-3').grade_data(:third_grade)
  end

  def test_it_can_load_and_add_test_data_from_a_file
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {:math => "./test/data/Avg_prof_CSAP_TCAP_by_race_Math.csv"}})
    expected = {2011 => {:math => 0.8169}, 2012 => {:math => 0.8182}, 2013 => {:math => 0.8053}, 2014 => {:math => 0.8}}
    assert_equal expected, str.find_by_name('academy 20').race_data(:asian)
  end

  def test_it_can_load_and_add_multiple_types_of_data_from_files
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {:third_grade => "./test/data/3rd_grade_prof_CSAP_TCAP.csv",
                                          :math => "./test/data/Avg_prof_CSAP_TCAP_by_race_Math.csv"}})
    expected_grade_data = {2010 => {:reading => 0.0}, 2008 => {:writing => 0.0}}
    assert_equal expected_grade_data, str.find_by_name('platte valley re-3').grade_data(:third_grade)

    expected_race_data = {2011 => {:math => 0.680}}
    assert_equal expected_race_data, str.find_by_name('platte valley re-3').race_data(:all_students)
  end

end
