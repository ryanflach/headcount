require_relative 'calculations'

class HeadcountAnalyst
  include Calculations

  attr_reader :district_repo

  def initialize(district_repo = nil)
    @district_repo = district_repo
  end

  def kindergarten_participation_rate_variation(district, comparison)
    data = kindergarten_district_and_comparison_data(district, comparison)
    truncate_float(
      find_average(data[:district]) / find_average(data[:comparison]))
  end

  def kindergarten_participation_rate_variation_trend(district, comparison)
    data = kindergarten_district_and_comparison_data(district, comparison)
    trend = data[:district].merge(data[:comparison]) do |year, dist, comp|
      truncate_float(dist / comp)
    end
  end

  def kindergarten_district_and_comparison_data(district, comp)
    district_data = district_kindergarten_enrollment_data(district)
    comp_data = district_kindergarten_enrollment_data(comp[comp.keys[0]])
    {:district => district_data, :comparison => comp_data}
  end

  def district_kindergarten_enrollment_data(district)
    district_repo.find_by_name(district).enrollment.kinder_participation_floats
  end

  def graduation_year_rate_variation(district, comparison)
    data = graduation_district_comparison_data(district, comparison)
    truncate_float(
      find_average(data[:district]) / find_average(data[:comparison]))
  end

  def graduation_district_comparison_data(district, comparison)
    district_data = district_graduation_data(district)
    comparison_data = district_graduation_data(comparison[comparison.keys[0]])
    {:district => district_data, :comparison => comparison_data}
  end

  def district_graduation_data(district)
    district_repo.find_by_name(district).enrollment.graduation_year_floats
  end

  def kindergarten_participation_against_high_school_graduation(dist)
    kinder =
      kindergarten_participation_rate_variation(dist, :against => "COLORADO")
    grad = graduation_year_rate_variation(dist, :against => "COLORADO")
    truncate_float(kinder / grad)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(comp)
    district = comp.values[0]
    if comp.keys[0] == :for
      if district.upcase == 'STATEWIDE'
        results = compare_all_schools
      else
        return kindergarten_participation_against_high_school_graduation(district).between?(0.6, 1.5)
      end
    else
      results = compare_across_multiple_districts(district)
    end
    calculate_correlation(results)
  end

  def compare_all_schools
    district_repo.districts.map do |district|
      next if colorado_or_no_data?(district)
      kindergarten_participation_against_high_school_graduation(district[0]).between?(0.6, 1.5)
    end
  end

  def colorado_or_no_data?(district)
    (district[0] == 'COLORADO' ||
    (no_kinder_data?(district[1]) || no_hs_data?(district[1])))
  end

  def compare_across_multiple_districts(districts)
    districts.map do |district_name|
      kindergarten_participation_against_high_school_graduation(district_name).between?(0.6, 1.5)
    end
  end

  def no_kinder_data?(district)
    district.no_kindergarten_participation?
  end

  def no_hs_data?(district)
    district.no_hs_grad_data?
  end

  def find_average(data)
    num_years_collected = data.count.to_f
    district_average = data.values.reduce(:+)
    district_average / num_years_collected
  end

end
