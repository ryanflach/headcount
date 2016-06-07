require './lib/district'
require 'csv'

class DistrictRepository
  attr_reader :districts

  def initialize(districts = [])
    @districts = districts
  end

  def add_district(district)
    @districts << district
  end

  def find_by_name(district_name)
    name = district_name.upcase
    return nil if districts.none? { |district| district.name == name }
    districts.find { |district| district.name == name}
  end

  def find_all_matching(name_fragment)
    name = name_fragment.upcase
    matches = districts.select { |district| district.name.include?(name) }
  end

  def load_data(header_label_and_file)
    filename = header_label_and_file.values[0].values[0]
    contents = CSV.open(filename, headers: true, header_converters: :symbol)
    contents.each do |row|
      name = row[:location]
      district = District.new({:name => name})
      add_district(district)
    end
  end
end
