module Calculations

  def truncate_float(float)
    (float.to_s.to_f * 1000).floor / 1000.0
  end

end
