class District
  attr_reader :name

  def initialize(name)
    @name = name[:name].upcase
  end
end
