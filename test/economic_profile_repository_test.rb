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

end
