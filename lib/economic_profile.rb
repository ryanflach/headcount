class EconomicProfile
  attr_accessor :econ_data

  def initialize(econ_data)
    @econ_data = econ_data
  end

  def name
    econ_data[:name].upcase
  end

  def median_household_income
    econ_data[:median_household_income]
  end

  def children_in_poverty
    econ_data[:children_in_poverty]
  end

  def free_or_reduced_price_lunch
    econ_data[:free_or_reduced_price_lunch]
  end

  def title_i
    econ_data[:title_i]
  end

end
