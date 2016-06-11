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

end
