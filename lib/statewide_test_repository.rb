require_relative 'enrollment'
require 'csv'

class StatewideTestRepository
  attr_reader :tests

  def initialize(tests = {})
    @tests = tests
  end

  def add_testing_data(data)
    @tests[data.name] = data
  end

  def find_by_name(district_name)
    tests[district_name.upcase]
  end

  def find_headers(filename)
    CSV.read(filename, headers: true, header_converters: :symbol).headers
  end

  def load_data(data_source)
    data_source.values[0].values.each_with_index do |filename, index|
      headers = find_headers
      CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
        name, year, percent = row[:location], row[:timeframe], row[:data]
        existing = find_by_name(name)
        if headers.include?(:race_ethnicity)
          data = {:race => row[:race_ethnicity], :name => name,
                  :subject => data_source.values[0].keys[index],
                  :year => year, :percent => percent, :existing => existing}
          merge_test_data(data)
        else
          merge_grade_data(existing, name, row[:score], year, percent)
        end
      end
    end
  end

  def merge_test_data(data)
    if data[:existing].nil?
      statewide_data = {:name => data[:name],
                        data[:subject] => {data[:race] =>
                        {data[:year] => data[:percent]}}}
      add_testing_data(StatewideTest.new(statewide_data)
    elsif data[:existing].test_data.has_key?(data[:subject])
      data[:existing].test_data[data[:subject]].merge!({data[:race] => })
  end


  # def enrollment_types
  #   {:kindergarten => :kindergarten_participation,
  #    :high_school_graduation => :high_school_graduation}
  # end
  #
  # def load_data(header_label_and_file)
  #   header_label_and_file.values[0].values.each_with_index do |filename, index|
  #     CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
  #       name, year, percent = row[:location], row[:timeframe].to_i, row[:data]
  #       grade_level = enrollment_types[header_label_and_file.values[0].keys[index]]
  #       existing = find_by_name(name)
  #       if existing.nil?
  #         add_enrollment(Enrollment.new({:name => name, grade_level => {year => percent}}))
  #       else
  #         grade_level_merge(existing, grade_level, year, percent)
  #       end
  #     end
  #   end
  # end
  #
  # def grade_level_merge(existing, grade_level, year, percent)
  #   if grade_level == :kindergarten_participation
  #     existing.kindergarten_participation.merge!({year => percent})
  #   else
  #     existing.high_school_graduation.merge!({year => percent})
  #   end
  # end

end
