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
      truncated[year] = percent.to_f
    end
  end

end
