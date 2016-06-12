class District

  def initialize(district_data, district_repo = nil)
    @district_data = district_data
    @district_repo = district_repo
  end

  def name
    @district_data[:name].upcase
  end

  def enrollment
    @district_repo.find_enrollment(name)
  end

  def statewide_test
    @district_repo.find_test_data(name)
  end

  def economic_profile
    @district_repo.find_econ_data(name)
  end

  def no_kindergarten_participation?
    enrollment.kindergarten_participation.nil? ||
    enrollment.kindergarten_participation.empty?
  end

  def no_hs_grad_data?
    enrollment.high_school_graduation.nil? ||
    enrollment.high_school_graduation.empty?
  end

end
