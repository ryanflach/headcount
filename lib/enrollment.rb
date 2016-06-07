class Enrollment
  attr_reader :name,
              :kindergarten_participation

  def initialize(enrollment_data)
    @name = enrollment_data[:name].upcase
    @kindergarten_participation = enrollment_data[:kindergarten_participation]
  end

  def kindergarten_participation_by_year
    truncated = {}
    kindergarten_participation.each do |year, percent|
      truncated[year] = percent.to_f.round(3)
    end
    truncated.sort_by {|year, percent| year}.to_h
  end

  def kindergarten_participation_in_year(year)
    data = kindergarten_participation_by_year
    return nil unless data.has_key?(year)
    data[year]
  end
end
