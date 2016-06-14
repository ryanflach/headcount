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

  def grade_check(grade)
    unless grade == 3 || grade == 8
      raise UnknownDataError, "#{grade} is not a known grade"
    end
  end

  def top_statewide_test_year_over_year_growth(data)
    raise InsufficientInformationError unless data.has_key?(:grade)
    grade_check(data[:grade])
    data[:subject].nil? ? subject = "all" : subject = data[:subject]
    data_set = check_subject_and_create_data(data[:grade], subject)
    sorted = data_set.sort_by {|name, growth| growth}.reverse
    data.has_key?(:top) ? top = data[:top] : top = 1
    result = []
    top.times do |index|
      result << [sorted[index][0], truncate_float(sorted[index][1])]
    end
    top == 1 ? result.flatten : result
  end

  def create_growth_of_aggregated_subjects(data)
    data.map do |name, subjects|
      sum = subjects.values.reduce(:+)
      [name, (sum/3)]
    end.to_h
  end

  def aggregate_all_subject_data(grade)
    math = test_data_for_grade_and_subject(grade, :math)
    reading = test_data_for_grade_and_subject(grade, :reading)
    writing = test_data_for_grade_and_subject(grade, :writing)
    {:math => math, :reading => reading, :writing => writing}
  end

  def aggregate_growth_for_all_subjects(subject_data)
    math_growth = calculate_growth(subject_data[:math], :math)
    reading_growth = calculate_growth(subject_data[:reading], :reading)
    writing_growth = calculate_growth(subject_data[:writing], :writing)
    {:math => math_growth, :reading => reading_growth,
     :writing => writing_growth}
  end

  def reduce_all_subject_growth_data(growth_data)
    reading_and_math = growth_data[:reading].map do |name, score|
      if growth_data[:math].keys.include?(name)
        growth_data[:reading][name].merge!(growth_data[:math][name])
      end
      [name, score]
    end.to_h
    growth_data[:writing].map do |name, score|
      if reading_and_math.keys.include?(name)
        growth_data[:writing][name].merge!(reading_and_math[name])
      end
      [name, score]
    end.to_h
  end

  def check_subject_and_create_data(grade, subject)
    if subject == "all"
      subject_data = aggregate_all_subject_data(grade)
      growth_data = aggregate_growth_for_all_subjects(subject_data)
      growth_reduced = reduce_all_subject_growth_data(growth_data)
      create_growth_of_aggregated_subjects(growth_reduced)
    else
      data = test_data_for_grade_and_subject(grade, subject)
      calculate_growth(data, subject).map do |name, subject|
        [name, subject.values[0]]
      end.to_h
    end
  end

  def calculate_growth(data, subject)
    data.map do |results|
      name = results[0]
      growth = growth_in_subject(results, subject)
      [name, growth]
    end.to_h
  end

  def test_data_for_grade_and_subject(grade, subject)
    district_repo.districts.map do |district|
      name = district[0]
      test_object = district_repo.find_by_name(name).statewide_test
      data = test_object.proficient_by_grade(grade).find_all do |year, subjects|
        subjects.include?(subject) && subjects[subject]!= 0.0
        end.to_h
      next if data.empty?
      first_year = data.keys.first
      last_year = data.keys.last
      starting_data = data[first_year][subject]
      ending_data = data[last_year][subject]
      [name, {first_year => starting_data, last_year => ending_data}]
    end.reject {|item| item.nil?}.to_h
  end

  def growth_in_subject(data, subject)
    first_year = data[1].keys.first
    last_year = data[1].keys.last
    num_years = last_year == first_year ? 1 : last_year - first_year
    {subject => (data[1][last_year] - data[1][first_year]) / num_years}
  end

end
