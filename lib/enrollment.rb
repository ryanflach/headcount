require_relative 'calculations'

class Enrollment
  include Calculations

  attr_accessor :enrollment_data

  def initialize(enrollment_data)
    @enrollment_data = enrollment_data
  end

  def name
    @enrollment_data[:name].upcase
  end

  def kindergarten_participation
    enrollment_data[:kindergarten_participation]
  end

  def high_school_graduation
    return enrollment_data[:high_school_graduation] if hs_grad_data_existing?
    @enrollment_data[:high_school_graduation] = {}
  end

  def hs_grad_data_existing?
    enrollment_data.has_key?(:high_school_graduation)
  end

  def kinder_participation_floats
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
    @enrollment_data[grade_level].map do |year, percent|
      [year, truncate_float(percent.to_f)]
    end.sort_by {|year, percent| year}.to_h
  end

  def data_in_year(query_year, grade_level)
    data = enrollment_data[grade_level].find do |year, percent|
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
