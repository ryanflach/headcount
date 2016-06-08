class Enrollment

  def initialize(enrollment_data)
    @enrollment_data = enrollment_data
  end

  def name
    @enrollment_data[:name].upcase
  end

  def truncate_float(float)
    (float * 1000).floor / 1000.0
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
