require_relative 'calculations'

class HeadcountAnalyst
  include Calculations

  attr_reader :district_repo

  def initialize(district_repo = nil)
    @district_repo = district_repo
  end

  def kindergarten_participation_rate_variation(district, comparison)
    data = kindergarten_district_and_comparison_data(district, comparison)
    truncate_float(find_average(data[:district]) / find_average(data[:comparison]))
  end

  def kindergarten_participation_rate_variation_trend(district, comparison)
    data = kindergarten_district_and_comparison_data(district, comparison)
    trend = data[:district].merge(data[:comparison]) do |year, dist_percent, comp_percent|
      truncate_float(dist_percent / comp_percent)
    end
  end

  def kindergarten_district_and_comparison_data(district, comparison)
    district_data = district_kindergarten_enrollment_data(district)
    comparison_data = district_kindergarten_enrollment_data(comparison[comparison.keys[0]])
    {:district => district_data, :comparison => comparison_data}
  end

  def district_kindergarten_enrollment_data(district)
    district_repo.find_by_name(district).enrollment.kindergarten_participation_floats
  end

  def graduation_year_rate_variation(district, comparison)
    data = graduation_district_comparison_data(district, comparison)
    truncate_float(find_average(data[:district]) / find_average(data[:comparison]))
  end

  def graduation_district_comparison_data(district, comparison)
    district_data = district_graduation_data(district)
    comparison_data = district_graduation_data(comparison[comparison.keys[0]])
    {:district => district_data, :comparison => comparison_data}
  end

  def district_graduation_data(district)
    district_repo.find_by_name(district).enrollment.graduation_year_floats
  end

  def kindergarten_participation_against_high_school_graduation(district)
    kinder_data = kindergarten_participation_rate_variation(district, :against => "COLORADO")
    grad_data = graduation_year_rate_variation(district, :against => "COLORADO")
    truncate_float(kinder_data / grad_data)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(path_and_district)
    results = []
    district = path_and_district.values[0]
    if path_and_district.keys[0] == :for
      if district.upcase == 'STATEWIDE'
        district_repo.districts.each do |district|
          district_object = district[1]
          col_or_none = (district[0] == 'COLORADO' || (no_kinder_data?(district_object) || no_hs_data?(district_object)))
          next if col_or_none
          results << kindergarten_participation_against_high_school_graduation(district[0]).between?(0.6, 1.5)
        end
      else
        return kindergarten_participation_against_high_school_graduation(district).between?(0.6, 1.5)
      end
    else
      district.each do |district_name|
        results << kindergarten_participation_against_high_school_graduation(district_name).between?(0.6, 1.5)
      end
    end
    num_true = results.find_all { |bool| bool == true }.count
    (num_true / results.count.to_f) > 0.70
  end

  def no_kinder_data?(district)
    # district.no_kindergarten_participation?
    district.enrollment.kindergarten_participation.empty?
  end

  def no_hs_data?(district)
    district.enrollment.high_school_graduation.empty?
  end

  def find_average(data)
    num_years_collected = data.count.to_f
    district_average = data.values.reduce(:+)
    district_average / num_years_collected
  end

end
