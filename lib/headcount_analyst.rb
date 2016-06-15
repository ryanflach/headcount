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
    return kpahsg(district)                                if for_district(comp, district)
    results = compare_all_schools                         if for_statewide(comp, district)
    results = compare_across_multiple_districts(district) if against_colorado(comp, district)
    calculate_correlation(results)
  end

  def kpahsg(district)
    kindergarten_participation_against_high_school_graduation(district).between?(0.6, 1.5)
  end

  def against_colorado(comp, district)
    comp.keys[0] != :for
  end

  def for_statewide(comp, district)
    comp.keys[0] == :for && district.upcase == 'STATEWIDE'
  end

  def for_district(comp, district)
    comp.keys[0] == :for && district.upcase != 'STATEWIDE'
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
    districts.map { |district| kpahsg(district) }
      # kindergarten_participation_against_high_school_graduation(district_name).between?(0.6, 1.5)
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

  def grade_check(g)
    raise UnknownDataError, "#{g} is not a known grade" unless g == 3 || g == 8
  end

  def weight_check(weights)
    unless weights.values.reduce(:+) == 1.0
      raise InsufficientInformationError, "Weights must add up to 1.0"
    end
  end

  def has_grade(data)
    raise InsufficientInformationError unless data.has_key?(:grade)
  end

  def check_data(data)
    has_grade(data)
    grade_check(data[:grade])
    weight_check(data[:weighting]) if data.has_key?(:weighting)
  end


  def top_statewide_test_year_over_year_growth(data)
    check_data(data)
    data[:weighting].nil? ? weighting = 0 : weighting = data[:weighting]
    data[:subject].nil? ? subject = "all" : subject = data[:subject]
    data_set = check_subject_and_create_data(data[:grade], subject, weighting)
    sorted = data_set.sort_by {|name, growth| growth}.reverse
    data.has_key?(:top) ? top = data[:top] : top = 1
    result = top.times.map do |index|
      [sorted[index][0], truncate_float(sorted[index][1])]
    end
    top == 1 ? result.flatten : result
  end

  def create_growth_of_aggregated_subjects(data, weights)
    if weights == 0
      data.map do |name, subjects|
        sum = subjects.values.reduce(:+)
        [name, (sum/3)]
      end.to_h
    else
      data.map do |name, subjects|
        [name, subjects.values.reduce(:+)]
      end
    end
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

  def reduce_all_subject_growth_data(growth_data, weighting)
    reading_and_math = growth_data[:reading].map do |name, score|
      if growth_data[:math].keys.include?(name)
        growth_data[:reading][name].merge!(growth_data[:math][name])
      end
      [name, score]
    end.to_h
    results = growth_data[:writing].map do |name, score|
      if reading_and_math.keys.include?(name)
        growth_data[:writing][name].merge!(reading_and_math[name])
      end
      [name, score]
    end.to_h
    if weighting == 0
      results
    else
      apply_weighting_by_category(results, weighting)
    end
  end

  def apply_weighting_by_category(data, weighting)
    data.map do |name, subjects|
      subjects[:math] *= weighting[:math] if subjects.has_key?(:math)
      subjects[:reading] *= weighting[:reading] if subjects.has_key?(:reading)
      subjects[:writing] *= weighting[:writing] if subjects.has_key?(:writing)
      [name, subjects]
    end.to_h
  end

  def check_subject_and_create_data(grade, subject, weighting)
    if subject == "all"
      subject_data = aggregate_all_subject_data(grade)
      growth_data = aggregate_growth_for_all_subjects(subject_data)
      growth_reduced = reduce_all_subject_growth_data(growth_data, weighting)
      create_growth_of_aggregated_subjects(growth_reduced, weighting)
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
      first_year, last_year = data.keys.first, data.keys.last
      data_start, data_end = data[first_year][subject], data[last_year][subject]
      [name, {first_year => data_start, last_year => data_end}]
    end.reject {|item| item.nil?}.to_h
  end

  def growth_in_subject(data, subject)
    first_year = data[1].keys.first
    last_year = data[1].keys.last
    num_years = last_year == first_year ? 1 : last_year - first_year
    {subject => (data[1][last_year] - data[1][first_year]) / num_years}
  end

end
