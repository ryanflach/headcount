require './lib/enrollment'
require 'csv'

class EnrollmentRepository
  attr_reader :enrollments

  def initialize(enrollments = [])
    @enrollments = enrollments
  end

  def add_enrollment(enrollment)
    @enrollments << enrollment
  end

  def find_by_name(name)
    name = name.upcase
    return nil if enrollments.none? { |enrollment| enrollment.name == name }
    enrollments.find { |enrollment| enrollment.name == name}
  end

  def load_data(header_label_and_file)
    filename = header_label_and_file.values[0].values[0]
    holding = {}
    CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
      name = row[:location]
      year = row[:timeframe].to_i
      percent = row[:data]
      holding = compare_and_create_enrollments(holding, name, year, percent)
    end
  end

  def compare_and_create_enrollments(holding, name, year, percent)
    if holding.empty?
      holding = {:name => name, :kindergarten_participation => {year => percent}}
    elsif holding.values.include?(name)
      holding[:kindergarten_participation].merge!({year => percent})
    else
      enrollment = Enrollment.new(holding)
      add_enrollment(enrollment)
      holding = {:name => name, :kindergarten_participation => {year => percent}}
    end
    holding
  end

end
