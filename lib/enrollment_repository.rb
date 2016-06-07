require './lib/enrollment'
require 'csv'

class EnrollmentRepository
  attr_reader :enrollments

  def initialize
    @enrollments = []
  end

  def add_enrollment(enrollment)
    @enrollments << enrollment
  end

  def load_data(header_label_and_file)
    filename = header_label_and_file.values[0].values[0]
    contents = CSV.open(filename, headers: true, header_converters: :symbol)
    holding = {}
    contents.each do |row|
      name = row[:location]
      year = row[:timeframe].to_i
      percent = row[:data]
      if holding.empty?
        holding = {:name => name, :kindergarten_participation => {year => percent}}
      elsif holding.values.include?(name)
        holding[:kindergarten_participation].merge!({year => percent})
      else
        enrollment = Enrollment.new(holding)
        add_enrollment(enrollment)
        holding = {:name => name, :kindergarten_participation => {year => percent}}
      end
    end
  end
end
