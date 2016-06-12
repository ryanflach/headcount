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

  def load_data(data_source)
    data_source.values[0].values.each_with_index do |filename, index|
      CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
        data = base_data(row)
        data_type = data_source.values[0].keys[index]
        existing = find_by_name(data[:name])
        if grade_levels.include?(data_type)
          data[:subject], data[:grade] = row[:score].downcase.to_sym, data_type
          add_grade_data(data, existing)
        else
          data[:race] = race_to_sym(row[:race_ethnicity])
          data[:subject] = data_type
          add_test_results(data, existing)
        end
      end
    end
  end

end
