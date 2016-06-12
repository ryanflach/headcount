require_relative 'test_helper'
require_relative '../lib/economic_profile_repository'

class EconomicProfileRepositoryTest < Minitest::Test

  def test_it_initializes_with_an_empty_hash_by_default
    epr = EconomicProfileRepository.new
    expected = {}
    assert_equal expected, epr.econ_profiles
  end

  def test_it_can_add_econ_profile_data_and_store_data
    epr = EconomicProfileRepository.new
    ep = EconomicProfile.new(:name => "Colorado")
    epr.add_econ_profile_data(ep)

    expected = {"COLORADO" => ep}
    assert_equal expected, epr.econ_profiles
  end

  def test_it_can_find_economic_profile_objects_by_name
    epr = EconomicProfileRepository.new
    ep = EconomicProfile.new(:name => "Colorado")
    epr.add_econ_profile_data(ep)

    expected = ep
    assert_equal expected, epr.find_by_name("Colorado")
  end

  def test_it_can_add_median_household_data_to_a_new_econ_object_and_store_in_repo
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2005-2009", :type => "Currency", :data => "50000"}
    existing = nil
    epr.add_median_household_data(data, existing)

    expected = {[2005, 2009] => 50000}
    assert_equal expected, epr.find_by_name("academy 20").median_household_income
  end

  def test_it_can_add_median_household_data_to_an_existing_econ_object_with_no_existing_median_data
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2005-2009", :type => "Currency", :data => "50000"}
    existing = EconomicProfile.new({:name => "academy 20"})
    epr.add_econ_profile_data(existing)
    epr.add_median_household_data(data, existing)

    expected = {[2005, 2009] => 50000}
    assert_equal expected, epr.find_by_name("academy 20").median_household_income
  end

  def test_it_can_add_to_existing_median_household_data
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2008-2012", :type => "Currency", :data => "60000"}
    existing = EconomicProfile.new({:name => "academy 20", :median_household_income => {[2005, 2009] => 50000}})
    epr.add_econ_profile_data(existing)
    epr.add_median_household_data(data, existing)

    expected = {[2005, 2009] => 50000, [2008, 2012] => 60000}
    assert_equal expected, epr.find_by_name("academy 20").median_household_income
  end

  def test_it_can_check_data_to_determine_percent_or_number_and_convert_to_int_or_float
    epr = EconomicProfileRepository.new
    data_p = {:type => "PERCENT", :data => "0.24252"}
    data_n = {:type => "number", :data => "245"}

    assert_equal 0.24252, epr.assign_percent_or_num(data_p)
    assert_equal 245, epr.assign_percent_or_num(data_n)
  end

  def test_it_will_store_only_poverty_percentage_data
    epr = EconomicProfileRepository.new
    data_n = {:name => "Academy 20", :year => "2008", :type => "number", :data => "2424"}
    data_p = {:name => "Academy 20", :year => "2008", :type => "percent", :data => "0.255"}
    existing = nil

    assert_nil epr.add_children_in_poverty(data_n, existing)

    epr.add_children_in_poverty(data_p, existing)
    expected = {2008 => 0.255}
    assert_equal expected, epr.find_by_name("academy 20").children_in_poverty
  end

  def test_it_can_add_poverty_data_to_a_new_econ_profile_object_and_store_in_repo
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2008", :type => "percent", :data => "0.255"}
    existing = nil
    epr.add_children_in_poverty(data, existing)

    expected = {2008 => 0.255}
    assert_equal expected, epr.find_by_name("academy 20").children_in_poverty
  end

  def test_it_can_add_poverty_data_to_an_existing_econ_profile_object_that_lacks_poverty_data
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2008", :type => "percent", :data => "0.255"}
    existing = EconomicProfile.new({:name => "academy 20"})
    epr.add_econ_profile_data(existing)
    epr.add_children_in_poverty(data, existing)

    expected = {2008 => 0.255}
    assert_equal expected, epr.find_by_name("academy 20").children_in_poverty
  end

  def test_it_can_add_poverty_data_to_an_existing_econ_profile_with_poverty_data
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2008", :type => "percent", :data => "0.255"}
    existing = EconomicProfile.new({:name => "academy 20", :children_in_poverty => {2005 => 0.298}})
    epr.add_econ_profile_data(existing)
    epr.add_children_in_poverty(data, existing)

    expected = {2005 => 0.298, 2008 => 0.255}
    assert_equal expected, epr.find_by_name("academy 20").children_in_poverty
  end

  def test_it_can_add_free_or_reduced_lunch_data_to_a_new_econ_profile_object_and_add_to_repo
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :lunch => {2008 => {:percentage => 0.445}}}
    existing = nil

    epr.add_lunch_data(data, existing)

    expected = {2008 => {:percentage => 0.445}}
    assert_equal expected, epr.find_by_name("academy 20").free_or_reduced_price_lunch
  end

  def test_it_can_add_free_or_reduced_lunch_data_to_an_existing_econ_profile_with_no_lunch_data
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :lunch => {2008 => {:percentage => 0.445}}}
    existing = EconomicProfile.new({:name => "Academy 20"})
    epr.add_econ_profile_data(existing)
    epr.add_lunch_data(data, existing)

    expected = {2008 => {:percentage => 0.445}}
    assert_equal expected, epr.find_by_name("academy 20").free_or_reduced_price_lunch

    data_n = {:name => "Academy 20", :lunch => {2008 => {:total => 105}}}
    epr.add_lunch_data(data_n, epr.find_by_name('academy 20'))
    expected = {2008 => {:percentage => 0.445, :total => 105}}
    assert_equal expected, epr.find_by_name('academy 20').free_or_reduced_price_lunch
  end

  def test_it_can_add_free_or_reduced_lunch_data_to_existing_that_lacks_data_for_that_year
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :lunch => {2008 => {:percentage => 0.445}}}
    existing = EconomicProfile.new({:name => "Academy 20", :free_or_reduced_price_lunch => {2009 => {:percentage => 0.523}}})
    epr.add_econ_profile_data(existing)
    epr.add_lunch_data(data, existing)

    expected = {2008 => {:percentage => 0.445}, 2009 => {:percentage => 0.523}}
    assert_equal expected, epr.find_by_name('academy 20').free_or_reduced_price_lunch
  end

  def test_it_can_add_title_i_data_to_a_new_econ_profile_object_and_add_to_repo
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2009", :type => "Percent", :data => "0.554"}
    existing = nil
    epr.add_title_i(data, existing)

    expected = {2009 => 0.554}
    assert_equal expected, epr.find_by_name('academy 20').title_i
  end

  def test_it_can_add_title_i_data_to_an_existing_econ_profile_object_that_lacks_title_i_data
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2009", :type => "Percent", :data => "0.554"}
    existing = EconomicProfile.new({:name => "Academy 20"})
    epr.add_econ_profile_data(existing)
    epr.add_title_i(data, existing)

    expected = {2009 => 0.554}
    assert_equal expected, epr.find_by_name('academy 20').title_i
  end

  def test_it_can_add_title_i_data_to_an_existing_econ_profile_object_that_has_title_i_data
    epr = EconomicProfileRepository.new
    data = {:name => "Academy 20", :year => "2009", :type => "Percent", :data => "0.554"}
    existing = EconomicProfile.new({:name => "Academy 20", :title_i => {2008 => 0.546}})
    epr.add_econ_profile_data(existing)
    epr.add_title_i(data, existing)

    expected = {2008 => 0.546, 2009 => 0.554}
    assert_equal expected, epr.find_by_name('academy 20').title_i
  end

  def test_it_can_load_and_store_median_income_data_from_a_file
    epr = EconomicProfileRepository.new
    epr.load_data({:economic_profile => {
                      :median_household_income => "./test/data/Median_household_income.csv"}})
    expected = {[2005, 2009] => 56222, [2006, 2010] => 56456, [2008, 2012] => 58244, [2007, 2011] => 57685, [2009, 2013] => 58433}
    assert_equal expected, epr.find_by_name('colorado').median_household_income
  end

  def test_it_can_load_and_store_poverty_data_from_a_file
    epr = EconomicProfileRepository.new
    epr.load_data({:economic_profile => {
                      :children_in_poverty => "./test/data/Children_in_poverty.csv"}})
    expected = {1995=>0.219, 1997=>0.252, 1999=>0.19, 2000=>0.196, 2001=>0.184,
                2002=>0.203, 2003=>0.208, 2004=>0.204, 2005=>0.195, 2006=>0.206,
                2007=>0.247, 2008=>0.22533, 2009=>0.24, 2010=>0.23185, 2011=>0.312,
                2012=>0.328, 2013=>0.264}
    assert_equal expected, epr.find_by_name('adams county 14').children_in_poverty
  end

  def test_it_can_load_and_store_free_or_reduced_price_lunch_data_from_a_file
    epr = EconomicProfileRepository.new
    epr.load_data({:economic_profile => {
                      :free_or_reduced_price_lunch => "./test/data/Free_reduced_lunch.csv"}})
    expected = {2014 => {:total => 485, :percentage => 0.58859}}
    assert_equal expected, epr.find_by_name('yuma school district 1').free_or_reduced_price_lunch
  end

  def test_it_can_load_and_store_title_i_data_from_a_file
    epr = EconomicProfileRepository.new
    epr.load_data({:economic_profile => {
                      :title_i => "./test/data/Title_i_students.csv"}})
    expected = {2009 => 0.216, 2011 => 0.224, 2012 => 0.22907, 2013 => 0.23178, 2014 => 0.23556}
    assert_equal expected, epr.find_by_name('colorado').title_i
  end

  def test_it_can_load_different_economic_data_from_multiple_files
    epr = EconomicProfileRepository.new
    epr.load_data({:economic_profile => {
                      :median_household_income => "./test/data/Median_household_income.csv",
                      :children_in_poverty => "./test/data/Children_in_poverty.csv",
                      :free_or_reduced_price_lunch => "./test/data/Free_reduced_lunch.csv",
                      :title_i => "./test/data/Title_i_students.csv"}})

    expected_median = {[2005, 2009] => 56222, [2006, 2010] => 56456, [2008, 2012] => 58244, [2007, 2011] => 57685, [2009, 2013] => 58433}
    expected_poverty = {1995=>0.219, 1997=>0.252, 1999=>0.19, 2000=>0.196, 2001=>0.184,
                        2002=>0.203, 2003=>0.208, 2004=>0.204, 2005=>0.195, 2006=>0.206,
                        2007=>0.247, 2008=>0.22533, 2009=>0.24, 2010=>0.23185, 2011=>0.312,
                        2012=>0.328, 2013=>0.264}
    expected_lunch = {2014 => {:total => 485, :percentage => 0.58859}}
    expected_title_i = {2009 => 0.216, 2011 => 0.224, 2012 => 0.22907, 2013 => 0.23178, 2014 => 0.23556}

    assert_equal expected_median, epr.find_by_name('colorado').median_household_income
    assert_equal expected_poverty, epr.find_by_name('adams county 14').children_in_poverty
    assert_equal expected_lunch, epr.find_by_name('yuma school district 1').free_or_reduced_price_lunch
    assert_equal expected_title_i, epr.find_by_name('colorado').title_i
  end
end
