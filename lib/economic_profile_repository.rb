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
    name, income = data[:name], data[:data].to_i
    year_range = data[:year].split('-').map {|year| year.to_i}
    if existing.nil?
      create_new_economic_profile([name, income, year_range], 'median')
    else
      merge_median_data_with_existing(existing, income, year_range)
    end
  end

  def merge_median_data_with_existing(existing, income, year_range)
    if existing.median_household_income.nil?
      existing.econ_data[:median_household_income] = {year_range => income}
    else
      existing.median_household_income.merge!({year_range => income})
    end
  end

  def merge_poverty_data_with_existing(existing, year, value)
    if existing.children_in_poverty.nil?
      existing.econ_data[:children_in_poverty] = {year => value}
    else
      existing.children_in_poverty.merge!({year => value})
    end
  end

  def merge_lunch_data_with_existing(existing, data)
    year = data[:free_or_reduced_price_lunch].keys[0]
    year_and_results = data[:free_or_reduced_price_lunch]
    if existing.free_or_reduced_price_lunch.nil?
      existing.econ_data[:free_or_reduced_price_lunch] = year_and_results
    elsif existing.free_or_reduced_price_lunch[year].nil?
      existing.free_or_reduced_price_lunch.merge!(year_and_results)
    else
      existing.free_or_reduced_price_lunch[year].merge!(year_and_results[year])
    end
  end

  def create_new_economic_profile(profile, type)
    if type == 'median'
      data = format_new_median_data(profile)
    elsif type == 'poverty'
      data = format_new_children_in_poverty_data(profile)
    else
      data = format_new_title_i_data(profile)
    end
    add_econ_profile_data(EconomicProfile.new(data))
  end

  def format_new_median_data(profile)
    name, income, year_range = profile[0], profile[1], profile[2]
    {:name => name, :median_household_income => {year_range => income}}
  end

  def format_new_children_in_poverty_data(profile)
    name, year, percent = profile[0], profile[1], profile[2]
    {:name => name, :children_in_poverty => {year => percent}}
  end

  def format_new_title_i_data(profile)
    name, year, percent = profile[0], profile[1], profile[2]
    {:name => name, :title_i => {year => percent}}
  end

  def add_children_in_poverty(data, existing)
    name, year = data[:name], data[:year].to_i
    value = assign_percent_or_num(data)
    if value.is_a?(Float)
      if existing.nil?
        create_new_economic_profile([name, year, value], 'poverty')
      else
        merge_poverty_data_with_existing(existing, year, value)
      end
    end
  end

  def add_free_or_reduced_lunch(data, existing)
    year, value = data[:year].to_i, assign_percent_or_num(data)
    profile = {:name => data[:name], :free_or_reduced_price_lunch => {}}
    if value.is_a?(Float)
      profile[:free_or_reduced_price_lunch] = {year => {:percentage => value}}
      add_lunch_data(profile, existing)
    else
      profile[:free_or_reduced_price_lunch] = {year => {:total => value}}
      add_lunch_data(profile, existing)
    end
  end

  def add_lunch_data(data, existing)
    if existing.nil?
      add_econ_profile_data(EconomicProfile.new(data))
    else
      merge_lunch_data_with_existing(existing, data)
    end
  end

  def merge_title_i_data_with_existing(existing, year, percent)
    if existing.title_i.nil?
      existing.econ_data[:title_i] = {year => percent}
    else
      existing.title_i.merge!({year => percent})
    end
  end

  def add_title_i(data, existing)
    name, year, percent = data[:name], data[:year].to_i, data[:data].to_f
    if existing.nil?
      create_new_economic_profile([name, year, percent], 'title_i')
    else
      merge_title_i_data_with_existing(existing, year, percent)
    end

  end

  def assign_percent_or_num(data)
    if data[:type].downcase.strip == "percent"
      data[:data].to_f
    else
      data[:data].to_i
    end
  end

  def base_data(row)
    {:name => row[:location], :year => row[:timeframe],
     :type => row[:dataformat], :data => row[:data]}
  end

end
