class District

  def initialize(district_data)
    @district_data = district_data
  end

  def name
    @district_data[:name].upcase
  end

  def enrollment
    @district_data[:enrollment]
  end

  def no_kindergarten_participation?
    @district_data[:enrollment].kindergarten_participation.empty?
  end

  def no_hs_grad_data?
    @district_data[:enrollment].high_school_graduation.empty?
  end

end
