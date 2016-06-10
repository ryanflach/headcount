require_relative 'calculations'

class StatewideTest
  include Calculations

  attr_accessor :test_data

  def initialize(test_data)
    @test_data = test_data
  end

  def name
    @test_data[:name].upcase
  end

  def proficient_by_grade(grade)
    #grade must be 3 or 8, raise UnknownDataError else
    #returns a hash grouped by year referencing percentages (truncated)
  end

  def proficient_by_race_or_ethnicity(race)
    # race as a symbol from the following set: [:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]
    # A call to this method with an unknown race should raise an UnknownRaceError.
    # The method returns a hash grouped by race referencing percentages by subject all as truncated three digit floats.
  end

  def proficient_for_subject_grade_in_year(subject, grade, year)
    # This method takes three parameters:
    # subject as a symbol from the following set: [:math, :reading, :writing]
    # grade as an integer from the following set: [3, 8]
    # year as an integer for any year reported in the data
    # A call to this method with any invalid parameter (like subject of :science) should raise an UnknownDataError.
    # The method returns a truncated three-digit floating point number representing a percentage.
  end

  def proficient_for_subject_by_race_in_year(subject, race, year)
    # This method take three parameters:
    # subject as a symbol from the following set: [:math, :reading, :writing]
    # race as a symbol from the following set: [:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]
    # year as an integer for any year reported in the data
    # A call to this method with any invalid parameter (like subject of :history) should raise an UnknownDataError.
    # The method returns a truncated three-digit floating point number representing a percentage.
  end



  def kindergarten_participation
    @test_data[:kindergarten_participation]
  end

  def high_school_graduation
    return @test_data[:high_school_graduation] if hs_grad_data_existing?
    @test_data[:high_school_graduation] = {}
  end

  def hs_grad_data_existing?
    @test_data.has_key?(:high_school_graduation)
  end

  def kindergarten_participation_floats
    floats_for_all_years(kindergarten_participation)
  end

  def graduation_year_floats
    floats_for_all_years(high_school_graduation)
  end

  def floats_for_all_years(grade_level)
    grade_level.map do |key, value|
      [key, value.to_f]
    end.sort_by {|year, percent| year}.to_h
  end

  def data_by_year(grade_level)
    @test_data[grade_level].map do |year, percent|
      [year, truncate_float(percent.to_f)]
    end.sort_by {|year, percent| year}.to_h
  end

  def data_in_year(query_year, grade_level)
    data = @test_data[grade_level].find do |year, percent|
      year == query_year
    end
    truncate_float(data[1].to_f) unless data.nil?
  end

  def kindergarten_participation_by_year
    data_by_year(:kindergarten_participation)
  end

  def kindergarten_participation_in_year(query_year)
    data_in_year(query_year, :kindergarten_participation)
  end

  def graduation_rate_by_year
    data_by_year(:high_school_graduation)
  end

  def graduation_rate_in_year(query_year)
    data_in_year(query_year, :high_school_graduation)
  end

end
