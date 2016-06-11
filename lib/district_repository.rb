require_relative 'district'
require_relative 'enrollment_repository'
require_relative 'statewide_test_repository'
require 'csv'

class DistrictRepository
  attr_reader :districts

  def initialize(districts = {})
    @districts = districts
    @enrollment = EnrollmentRepository.new
    @statewide_testing = StatewideTestRepository.new
  end

  def add_district(district)
    @districts[district.name] = district
  end

  def find_by_name(district_name)
    districts[district_name.upcase]
  end

  def find_all_matching(name_fragment)
    matches = districts.keys.select { |key| key.include?(name_fragment.upcase) }
    matches.map { |match| districts[match] }
  end

  def load_data(data_source)
    data_source.keys.each do |repo_type|
      repo = check_repository_type(repo_type)
      repo.load_data({repo_type => data_source[repo_type]})
    end
    data_source.values.each do |repository|
      repository.each do |subject, file|
        CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
          name = row[:location]
          district = District.new({:name => name}, self)
          add_district(district)
        end
      end
    end
  end

  def check_repository_type(key)
    possible_repos[key]
  end

  def possible_repos
    {:enrollment => @enrollment, :statewide_testing => @statewide_testing}
  end

  def find_enrollment(name)
    @enrollment.find_by_name(name)
  end

  def find_test_data(name)
    @statewide_testing.find_by_name(name)
  end

end
