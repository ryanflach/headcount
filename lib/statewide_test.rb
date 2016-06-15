require_relative 'calculations'
require_relative 'errors'

class StatewideTest
  include Calculations

  attr_accessor :test_data

  def initialize(test_data)
    @test_data = test_data
  end

  def name
    test_data[:name].upcase
  end

  def grade_data(grade)
    test_data[grade]
  end

  def race_data(race)
    test_data[race]
  end

  def grade_year_data(grade, year)
    grade_data(grade)[year] unless grade_data(grade).nil? || grade.nil?
  end

  def race_year_data(race, year)
    race_data(race)[year] unless race_data(race).nil? || race.nil?
  end

  def proficient_by_grade(grade)
    raise UnknownDataError unless grade == 3 || grade == 8
    sort_and_truncate(grade_data(grade_level_symbols[grade]))
  end

  def proficient_by_race_or_ethnicity(race)
    raise UnknownRaceError unless races.has_key?(race)
    sort_and_truncate(race_data(races[race]))
  end

  def proficient_for_subject_by_grade_in_year(subject, grade, year)
    raise UnknownDataError unless data_exists(subject, grade, year)
    result = proficient_by_grade(grade)[year][subject]
    result == 0.0 ? "N/A" : result
  end

  def proficient_for_subject_by_race_in_year(subject, race, year)
    raise UnknownDataError unless data_exists(subject, race, year)
    result = proficient_by_race_or_ethnicity(race)[year][subject]
    result == 0.0 ? "N/A" : result
  end

  private

  def sort_and_truncate(data)
    data.map do |year_or_race, subjects|
      sorted_subjects = subjects.map do |subject, percent|
        [subject, truncate_float(percent)]
      end.sort_by {|subject, percent| subject }.to_h
      [year_or_race, sorted_subjects]
    end.sort_by {|year_or_race, subject| year_or_race}.to_h
  end

  def data_exists(subject, grade_or_race, year)
    has_subject?(subject) && has_race_or_grade_in_year?(grade_or_race, year)
  end

  def has_subject?(subject)
    subjects.include?(subject)
  end

  def has_race(race, year)
    race_year_data(races[race], year)
  end

  def has_grade(grade, year)
    grade_year_data(grade_level_symbols[grade], year)
  end

  def has_race_or_grade_in_year?(grade_or_race, year)
    has_grade(grade_or_race, year) || has_race(grade_or_race, year)
  end

  def races
    {:two_or_more => :two_or_more, :all_students => :all_students,
     :asian => :asian, :black => :black,
     :pacific_islander => :hawaiian_pacific_islander,
     :hispanic => :hispanic, :native_american => :native_american,
     :white => :white}
  end

  def subjects
    [:math, :reading, :writing]
  end

  def grade_level_symbols
    {3 => :third_grade, 8 => :eighth_grade}
  end

end
