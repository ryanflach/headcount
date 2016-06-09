require_relative 'enrollment'
require 'csv'

class StatewideTestRepository
  attr_reader :test_data

  def initialize(test_data = {})
    @test_data = test_data
  end

  def add_testing_data(data)
    @test_data[data.name] = data
  end

  def find_by_name(district_name)
    test_data[district_name.upcase]
  end

  def enrollment_types
    {:kindergarten => :kindergarten_participation,
     :high_school_graduation => :high_school_graduation}
  end

  def load_data(header_label_and_file)
    header_label_and_file.values[0].values.each_with_index do |filename, index|
      CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
        name, year, percent = row[:location], row[:timeframe].to_i, row[:data]
        grade_level = enrollment_types[header_label_and_file.values[0].keys[index]]
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
