require_relative 'calculations'

class Enrollment
  include Calculations

  attr_accessor :enrollment_data

  def initialize(enrollment_data)
    @enrollment_data = enrollment_data
  end

  def kindergarten_participation
    @enrollment_data[:kindergarten_participation]
  end

  def kindergarten_participation_floats
    kindergarten_participation.map do |key, value|
      [key, value.to_f]
    end.sort_by {|year, percent| year}.to_h
  end

  def name
    @enrollment_data[:name].upcase
  end

  def kindergarten_participation_by_year
    @enrollment_data[:kindergarten_participation].map do |year, percent|
      [year, truncate_float(percent.to_f)]
    end.sort_by {|year, percent| year}.to_h
  end

  def kindergarten_participation_in_year(query_year)
    data = @enrollment_data[:kindergarten_participation].find do |year, percent|
      year == query_year
    end
    truncate_float(data[1].to_f) unless data.nil?
  end
  
end
