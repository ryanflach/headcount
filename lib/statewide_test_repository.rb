require_relative 'statewide_test'
require 'csv'

class StatewideTestRepository
  attr_reader :tests

  def initialize(tests = {})
    @tests = tests
  end

  def add_testing_data(data)
    @tests[data.name] = data
  end

  def find_by_name(district_name)
    tests[district_name.upcase]
  end

  def grade_levels
    [:third_grade, :eigth_grade]
  end

  def base_data(row)
    {:name => row[:location], :year => row[:timeframe].to_i,
     :percent => row[:data].to_f}
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
          data[:race], data[:subject], = race_to_sym(row[:race_ethnicity]), data_type
          add_test_results(data, existing)
        end
      end
    end
  end

  def race_to_sym(race)
    race.downcase.strip.gsub(/[^'a-z']/, '_').to_sym
  end

  def add_grade_data(data, existing)
    statewide_data = {:name => data[:name],
                      data[:grade] =>
                     {data[:year] => {data[:subject] => data[:percent]}}}
    if existing.nil?
      add_testing_data(StatewideTest.new(statewide_data))
    elsif has_grade_and_year(existing, data[:grade], data[:year])
      existing.year_data(data[:grade], data[:year]).merge!({data[:subject] => data[:percent]})
    elsif has_grade(existing, data[:grade])
      existing.grade_data(data[:grade])[data[:year]] = {data[:subject] => data[:percent]}
    else
      existing.test_data[data[:grade]] = {data[:year] => {data[:subject] => data[:percent]}}
    end
  end

  def add_test_results(data, existing)
    statewide_data = {:name => data[:name],
                      data[:race] =>
                     {data[:year] => {data[:subject] => data[:percent]}}}
    if existing.nil?
      add_testing_data(StatewideTest.new(statewide_data))
    elsif has_race_and_year(existing, data[:race], data[:year])
      existing.year_data(data[:race], data[:year]).merge!({data[:subject] => data[:percent]})
    elsif has_race(existing, data[:race])
      existing.race_data(data[:race])[data[:year]] = {data[:subject] => data[:percent]}
    else
      existing.test_data[data[:race]] = {data[:year] => {data[:subject] => data[:percent]}}
    end
  end

  def has_grade(test_object, grade)
    test_object.grade_data(grade)
  end

  def has_year(test_object, grade_or_race, year)
    test_object.year_data(grade_or_race, year)
  end

  def has_grade_and_year(object, grade, year)
    has_grade(object, grade) && has_year(object, grade, year)
  end

  def has_race(test_object, race)
    test_object.race_data(race)
  end

  def has_race_and_year(object, race, year)
    has_race(object, race) && has_year(object, race, year)
  end

end
