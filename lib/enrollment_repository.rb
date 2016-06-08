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

  def load_data(header_label_and_file)
    filename = header_label_and_file.values[0].values[0]
    CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
      name = row[:location]
      year = row[:timeframe].to_i
      percent = row[:data]
      enrollment = Enrollment.new({:name => name, :kindergarten_participation => {year => percent}})
      existing = find_by_name(enrollment.name)
      if existing.nil?
        add_enrollment(enrollment)
      else
        existing.kindergarten_participation.merge!({year => percent})
      end
    end
  end

end
