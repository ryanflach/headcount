require_relative 'errors'

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
    
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)

  end

  def free_or_reduce_price_lunch_number_in_year(year)

  end

  def title_i_in_year(year)

  end

end
