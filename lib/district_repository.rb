require_relative 'district'
require_relative 'enrollment_repository'
require 'csv'

class DistrictRepository
  attr_reader :districts

  def initialize(districts = {})
    @districts = districts
    @enrollment = EnrollmentRepository.new
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

  def load_data(header_label_and_file)
    repo = check_repository_type(header_label_and_file.keys.first)
    repo.load_data(header_label_and_file)
    filename = header_label_and_file.values[0].values[0]
    CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
      name = row[:location]
      if repo.enrollments[name.upcase]
        district = District.new({:name => name, :enrollment => repo.enrollments[name.upcase]})
      else
        district = District.new({:name => name})
      end
      add_district(district)
    end
  end

  def check_repository_type(key)
    possible_repos[key]
  end

  def possible_repos
    {:enrollment => @enrollment}
  end

end
