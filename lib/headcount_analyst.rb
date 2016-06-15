require_relative 'calculations'
require_relative 'errors'

class HeadcountAnalyst
  include Calculations

  attr_reader :district_repo

  def initialize(district_repo = nil)
    @district_repo = district_repo
  end

  def kindergarten_participation_rate_variation(dist, comp)
    data = kindergarten_district_and_comparison_data(dist, comp)
    truncate_float(
      find_average(data[:district]) / find_average(data[:comparison]))
  end

  def kindergarten_participation_rate_variation_trend(dist, comp)
    data = kindergarten_district_and_comparison_data(dist, comp)
    data[:district].merge(data[:comparison]) do |year, dist, comp|
      truncate_float(dist / comp)
    end
  end

  def kindergarten_district_and_comparison_data(dist, comp)
    district_data = district_kindergarten_enrollment_data(dist)
    comp_data = district_kindergarten_enrollment_data(comp[comp.keys[0]])
    {:district => district_data, :comparison => comp_data}
  end

  def district_kindergarten_enrollment_data(dist)
    district_repo.find_by_name(dist).enrollment.kinder_participation_floats
  end

  def graduation_year_rate_variation(dist, comp)
    data = graduation_district_comparison_data(dist, comp)
    truncate_float(
      find_average(data[:district]) / find_average(data[:comparison]))
  end

  def graduation_district_comparison_data(dist, comp)
    district_data = district_graduation_data(dist)
    comparison_data = district_graduation_data(comp[comp.keys[0]])
    {:district => district_data, :comparison => comparison_data}
  end

  def district_graduation_data(dist)
    district_repo.find_by_name(dist).enrollment.graduation_year_floats
  end

  def kindergarten_participation_against_high_school_graduation(dist)
    k = kindergarten_participation_rate_variation(dist, :against => "COLORADO")
    g = graduation_year_rate_variation(dist,            :against => "COLORADO")
    truncate_float(k / g)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(comp)
    dist = comp.values[0]
    return correlation?(dist)                  if for_district(comp, dist)
    results = compare_all_schools              if for_statewide(comp, dist)
    results = compare_multiple_districts(dist) if against_colorado(comp, dist)
    calculate_correlation(results)
  end

  def correlation?(dist)
    kinder_hs = kindergarten_participation_against_high_school_graduation(dist)
    kinder_hs.between?(0.6, 1.5)
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
      correlation?(district[0])
    end
  end

  def colorado_or_no_data?(district)
    (district[0] == 'COLORADO' ||
    (no_kinder_data?(district[1]) || no_hs_data?(district[1])))
  end

  def compare_multiple_districts(districts)
    districts.map { |district| correlation?(district) }
  end

  def no_kinder_data?(district)
    district.no_kindergarten_participation?
  end

  def no_hs_data?(district)
    district.no_hs_grad_data?
  end

  def grade_check(grade)
    unless grade == 3 or grade == 8
      raise UnknownDataError, "#{grade} is not a known grade"
    end
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
    weighting = data[:weighting] ? data[:weighting] : weighting = 0
    subject = data[:subject] ? data[:subject] : subject = "all"
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

  def aggregate_growth_for_all_subjects(subject)
    growth = Hash.new
    growth[:math] =    calculate_growth(subject[:math], :math)
    growth[:reading] = calculate_growth(subject[:reading], :reading)
    growth[:writing] = calculate_growth(subject[:writing], :writing)
    growth
  end

  def reduce_all_subject_growth_data(growth_data, weighting)
    reading_and_math = reading_math_growth_data(growth_data, weighting)
    results = growth_data[:writing].map do |name, score|
      if reading_and_math.keys.include?(name)
        growth_data[:writing][name].merge!(reading_and_math[name])
      end
      [name, score]
    end.to_h
    weighting == 0 ? results : apply_weighting_by_category(results, weighting)
  end

  def reading_math_growth_data(growth_data, weighting)
    growth_data[:reading].map do |name, score|
      if growth_data[:math].keys.include?(name)
        growth_data[:reading][name].merge!(growth_data[:math][name])
      end
      [name, score]
    end.to_h
  end

  def apply_weighting_by_category(data, weighting)
    data.map do |name, subjects|
      subjects[:math]    *= weighting[:math]    if subjects.has_key?(:math)
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
      [results[0], growth_in_subject(results, subject)]
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
