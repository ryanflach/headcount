require_relative 'calculations'
require_relative 'errors'

class EconomicProfile
  include Calculations

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

  def median_household_income_in_year(year)
    data = median_household_income.find_all do |year_range, income|
      year.between?(year_range.first, year_range.last)
    end
    raise UnknownDataError if data.empty?
    total = data.reduce(0) {|result, values| result += values[1]}
    total / data.count
  end

  def median_household_income_average
    incomes_all_years = median_household_income.values
    total = incomes_all_years.reduce(:+)
    total / incomes_all_years.count
  end

  def children_in_poverty_in_year(year)
    raise UnknownRaceError unless children_in_poverty.has_key?(year)
    truncate_float(children_in_poverty[year])
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    raise UnknownRaceError unless free_or_reduced_price_lunch.has_key?(year)
    truncate_float(free_or_reduced_price_lunch[year][:percentage])
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    raise UnknownRaceError unless free_or_reduced_price_lunch.has_key?(year)
    free_or_reduced_price_lunch[year][:total]
  end

  def title_i_in_year(year)
    raise UnknownRaceError unless title_i.has_key?(year)
    truncate_float(title_i[year])
  end

end
