require_relative 'test_helper'
require_relative '../lib/economic_profile'

class EconomicProfileTest < Minitest::Test

  def test_it_initializes_with_a_hash_of_test_data
    ep = EconomicProfile.new({:name => "Colorado"})
    assert_instance_of EconomicProfile, ep
  end

  def test_it_holds_relevant_economic_profile_data
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)
    assert_equal "ACADEMY 20", ep.name

    expected = {[2005, 2009] => 50000, [2008, 2014] => 60000}
    assert_equal expected, ep.median_household_income

    expected = {2012 => 0.1845}
    assert_equal expected, ep.children_in_poverty

    expected = {2014 => {:percentage => 0.023, :total => 100}}
    assert_equal expected, ep.free_or_reduced_price_lunch

    expected = {2015 => 0.543}
    assert_equal expected, ep.title_i
  end

  def test_it_raises_an_unknown_data_error_for_median_income_in_year_if_year_is_not_present
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_raises(UnknownDataError) do
      ep.median_household_income_in_year(2004)
    end
  end

  def test_it_can_find_the_average_median_household_income_in_a_given_year
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_equal 55000, ep.median_household_income_in_year(2008)
    assert_equal 60000, ep.median_household_income_in_year(2010)
  end

  def test_it_can_find_the_median_household_income_average_across_all_years
    data = {:median_household_income => {[2005, 2009] => 85060, [2006, 2010] => 85450},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_equal 85255, ep.median_household_income_average
  end

  def test_it_raises_an_unknown_data_error_for_children_in_poverty_in_a_given_year_if_no_data_exists
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_raises(UnknownDataError) do
      ep.children_in_poverty_in_year(2010)
    end
  end

  def test_it_returns_a_truncated_float_for_children_in_poverty_in_a_given_year
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845, 2013 => 0.6543},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_equal 0.184, ep.children_in_poverty_in_year(2012)
    assert_equal 0.654, ep.children_in_poverty_in_year(2013)
  end

  def test_it_raises_an_unknown_data_error_free_or_reduced_price_lunch_percentage_in_a_given_year_if_no_data_exists
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_raises(UnknownDataError) do
      ep.free_or_reduced_price_lunch_percentage_in_year(2010)
    end
  end

  def test_it_returns_a_truncated_float_for_free_or_reduced_price_lunch_percentage_in_a_given_year
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.0234, :total => 100},
                                             2007 => {:percentage => 0.07632, :total => 7654}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_equal 0.023, ep.free_or_reduced_price_lunch_percentage_in_year(2014)
    assert_equal 0.076, ep.free_or_reduced_price_lunch_percentage_in_year(2007)
  end

  def test_it_raises_an_unknown_data_error_for_free_or_reduced_price_lunch_number_in_a_given_year_if_no_data
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_raises(UnknownDataError) do
      ep.free_or_reduced_price_lunch_number_in_year(2012)
    end
  end

  def test_it_returns_an_int_for_number_of_children_receiving_free_or_reduced_price_lunch_in_a_given_year
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.0234, :total => 100},
                                             2007 => {:percentage => 0.0234, :total => 7654}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_equal 100, ep.free_or_reduced_price_lunch_number_in_year(2014)
    assert_equal 7654, ep.free_or_reduced_price_lunch_number_in_year(2007)
  end

  def test_it_raises_an_unknown_data_error_for_title_i_in_year_if_no_data_exists
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_raises(UnknownDataError) do
      ep.title_i_in_year(2012)
    end
  end

  def test_it_returns_a_truncated_float_for_title_i_in_a_given_year
    data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.0234, :total => 100}},
            :title_i => {2015 => 0.5436, 2007 => 0.7866},
            :name => "ACADEMY 20"
            }
    ep = EconomicProfile.new(data)

    assert_equal 0.543, ep.title_i_in_year(2015)
    assert_equal 0.786, ep.title_i_in_year(2007)
  end

end
