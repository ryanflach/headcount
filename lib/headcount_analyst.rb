require_relative 'calculations'

class HeadcountAnalyst
  include Calculations

  attr_reader :district_repo

  def initialize(district_repo = nil)
    @district_repo = district_repo
  end

  def kindergarten_participation_rate_variation(district, comparison)
    district_data = district_repo.find_by_name(district).enrollment.kindergarten_participation_floats
    comparison_type = comparison.keys[0]
    comparison_data = district_repo.find_by_name(comparison[comparison_type]).enrollment.kindergarten_participation_floats
    truncate_float(find_average(district_data) / find_average(comparison_data))
  end

  def kindergarten_participation_rate_variation_trend(district, comparison)
    district_data = district_repo.find_by_name(district).enrollment.kindergarten_participation_floats
    comparison_type = comparison.keys[0]
    comparison_data = district_repo.find_by_name(comparison[comparison_type]).enrollment.kindergarten_participation_floats
    trend = district_data.merge(comparison_data) do |year, district_percent, comparison_percent|
      truncate_float(district_percent / comparison_percent)
    end
  end

  def find_average(data)
    years_collected = data.count.to_f
    district_average = data.values.reduce(:+)
    district_average / years_collected
  end

end
