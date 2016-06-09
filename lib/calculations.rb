module Calculations

  def truncate_float(float)
    float = 0.0 if float.nan?
    (float * 1000).floor / 1000.0
  end

  def calculate_correlation(results)
    num_true = results.find_all { |result| result == true}.count
    (num_true / results.count.to_f) > 0.70
  end

end
