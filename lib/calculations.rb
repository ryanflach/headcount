module Calculations

  def truncate_float(float)
    float = 0.0 if float.nan?
    (float * 1000).floor / 1000.0
  end

  def calculate_correlation(results)
    num_true = results.find_all { |result| result == true}.count
    (num_true / results.count.to_f) > 0.70
  end

  def find_average(data)
    num_years_collected = data.count.to_f
    district_average = data.values.reduce(:+)
    district_average / num_years_collected
  end

end
