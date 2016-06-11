require_relative 'economic_profile'
require 'csv'

class EconomicProfileRepository
  attr_reader :econ_profiles

  def initialize(econ_profiles = {})
    @econ_profiles = econ_profiles
  end

  def add_econ_profile_data(data)
    @econ_profiles[data.name] = data
  end

  def find_by_name(district_name)
    econ_profiles[district_name.upcase]
  end

end
