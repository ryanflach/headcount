require_relative 'enrollment'
require 'csv'

class EnrollmentRepository
  attr_reader :enrollments

  def initialize(enrollments = {})
    @enrollments = enrollments
  end

  def add_enrollment(enrollment)
    @enrollments[enrollment.name] = enrollment
  end

  def find_by_name(district_name)
    enrollments[district_name.upcase]
  end

  def enrollment_types
    {:kindergarten => :kindergarten_participation,
     :high_school_graduation => :high_school_graduation}
  end

  def load_data(data_source)
    data_source.values[0].values.each_with_index do |filename, index|
      CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
        name, year, percent = row[:location], row[:timeframe].to_i, row[:data]
        grade_level = enrollment_types[data_source.values[0].keys[index]]
        existing = find_by_name(name)
        if existing.nil?
          add_enrollment(Enrollment.new({:name => name, grade_level => {year => percent}}))
        else
          grade_level_merge(existing, grade_level, year, percent)
        end
      end
    end
  end

  def grade_level_merge(existing, grade_level, year, percent)
    if grade_level == :kindergarten_participation
      existing.kindergarten_participation.merge!({year => percent})
    else
      existing.high_school_graduation.merge!({year => percent})
    end
  end

end
