require_relative 'economic_profile'
require 'csv'

class EconomicProfileRepository
  attr_reader :econ_profiles

  def initialize(econ_profiles = {})
    @econ_profiles = econ_profiles
  end

  def add_econ_profile_data(data)
    @econ_profiles[data.name] = data
  end

  def find_by_name(district_name)
    econ_profiles[district_name.upcase]
  end

  def base_data(row)
    {:name => row[:location], :year => row[:timeframe],
     :type => row[:dataformat], :data => row[:data]}
  end

  def load_data(data_source)
    data_source.values[0].values.each_with_index do |filename, index|
      CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
        data = base_data(row)
        data_type = data_source.values[0].keys[index]
        if data_type == :free_or_reduced_price_lunch
          next unless row[:poverty_level].strip.downcase.include?('free or')
        end
        existing = find_by_name(data[:name])
        check_data_type_and_add_to_repo(data, data_type, existing)
      end
    end
  end

  def check_data_type_and_add_to_repo(data, data_type, existing)
    if data_type == :median_household_income
      add_median_household_data(data, existing)
    elsif data_type == :children_in_poverty
      add_children_in_poverty(data, existing)
    elsif data_type == :free_or_reduced_price_lunch
      add_free_or_reduced_lunch(data, existing)
    else
      add_title_i(data, existing)
    end
  end

  def add_median_household_data(data, existing)
    income = data[:data].to_i
    year_range = data[:year].split('-').map {|year| year.to_i}
    if existing.nil?
      econ_profile = {:name => data[:name],
                      :median_household_income => {year_range => income}}
      add_econ_profile_data(EconomicProfile.new(econ_profile))
    elsif existing.median_household_income.nil?
      existing.econ_data[:median_household_income] = {year_range => income}
    else
      existing.median_household_income.merge!({year_range => income})
    end
  end

  def add_children_in_poverty(data, existing)
    value = assign_percent_or_num(data)
    year = data[:year].to_i
    if value.is_a?(Float)
      if existing.nil?
        econ_profile = {:name => data[:name],
                        :children_in_poverty => {year => value}}
        add_econ_profile_data(EconomicProfile.new(econ_profile))
      elsif existing.children_in_poverty.nil?
        existing.econ_data[:children_in_poverty] = {year => value}
      else
        existing.children_in_poverty.merge!({year => value})
      end
    end
  end

  def add_free_or_reduced_lunch(data, existing)
    value = assign_percent_or_num(data)
    year = data[:year].to_i
    econ_profile = {:name => data[:name], :lunch => {}}
    if value.is_a?(Float)
      econ_profile[:lunch] = {year => {:percentage => value}}
      add_lunch_data(econ_profile, existing)
    else
      econ_profile[:lunch] = {year => {:total => value}}
      add_lunch_data(econ_profile, existing)
    end
  end

  def add_lunch_data(data, existing)
    year = data[:lunch].keys[0]
    if existing.nil?
      data[:free_or_reduced_price_lunch] = data[:lunch]
      data.delete(:lunch)
      add_econ_profile_data(EconomicProfile.new(data))
    elsif existing.free_or_reduced_price_lunch.nil?
      existing.econ_data[:free_or_reduced_price_lunch] = data[:lunch]
    elsif existing.free_or_reduced_price_lunch[year].nil?
      existing.free_or_reduced_price_lunch.merge!(data[:lunch])
    else
      existing.free_or_reduced_price_lunch[year].merge!(data[:lunch][year])
    end
  end

  def add_title_i(data, existing)
    value = data[:data].to_f
    year = data[:year].to_i
    if existing.nil?
      econ_profile = {:name => data[:name],
                      :title_i => {year => value}}
      add_econ_profile_data(EconomicProfile.new(econ_profile))
    elsif existing.title_i.nil?
      existing.econ_data[:title_i] = {year => value}
    else
      existing.title_i.merge!({year => value})
    end
  end

  def assign_percent_or_num(data)
    if data[:type].downcase.strip == "percent"
      data[:data].to_f
    else
      data[:data].to_i
    end
  end

end
