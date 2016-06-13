require_relative 'calculations'
require_relative 'errors'

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

  def top_statewide_test_year_over_year_growth(data)
    raise InsufficientInformationError unless data.has_key?(:grade)
    raise UnknownDataError, "#{data[:grade]} is not a known grade" unless data[:grade] == 3 || data[:grade] == 8
    data_set = test_data_for_grade(data[:grade])
    growth_only = data_set.map do |results|
      name = results[0]
      growth = growth_in_all_subjects(results)
      [name, growth]
    end.to_h
    sorted = growth_only.sort_by {|name, subjects| subjects[data[:subject]]}.reverse
    data.has_key?(:top) ? top = data[:top] : top = 1
    result = []
    top.times do |index|
      result << [sorted[index][0], truncate_float(sorted[index][1][data[:subject]])]
    end
    top == 1 ? result.flatten : result
  end

  def test_data_for_grade(grade)
    district_repo.districts.map do |district|
      name = district[0]
      test_object = district_repo.find_by_name(name).statewide_test
      first_year = test_object.proficient_by_grade(grade).keys.first
      last_year = test_object.proficient_by_grade(grade).keys.last
      starting_data = test_object.proficient_by_grade(grade).values.first
      ending_data = test_object.proficient_by_grade(grade).values.last
      [name, {first_year => starting_data, last_year => ending_data}]
    end.to_h
  end

  def growth_in_all_subjects(data)
    first_year = data[1].keys.first
    last_year = data[1].keys.last
    if data[1][last_year][:math].nil? || data[1][first_year][:math].nil?
      math = 0.0
    else
      math = (data[1][last_year][:math] - data[1][first_year][:math]) / (last_year - first_year)
    end
    if data[1][last_year][:reading].nil? || data[1][first_year][:reading].nil?
      reading = 0.0
    else
      reading = (data[1][last_year][:reading] - data[1][first_year][:reading]) / (last_year - first_year)
    end
    if data[1][last_year][:writing].nil? || data[1][first_year][:writing].nil?
      writing = 0.0
    else
      writing = (data[1][last_year][:writing] - data[1][first_year][:writing]) / (last_year - first_year)
    end
    math = 0.0 if math.nan?
    reading = 0.0 if reading.nan?
    writing = 0.0 if writing.nan?
    {:math => math, :reading => reading, :writing => writing}
  end

end
