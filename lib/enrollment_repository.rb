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

  def load_data(header_label_and_file)
    num_files = header_label_and_file.values[0].values.count
    num_files.times do |num|
      filename = header_label_and_file.values[0].values[num]
      CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
        name = row[:location]
        year = row[:timeframe].to_i
        percent = row[:data]
        grade_level = enrollment_types[header_label_and_file.values[0].keys[num]]
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
