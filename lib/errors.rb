class UnknownDataError < StandardError
  attr_reader :message

  def initialize(message = "Data unavailable")
    @message = message
  end
end

class UnknownRaceError < UnknownDataError
end

class InsufficientInformationError < StandardError
  attr_reader :message

  def initialize(message = "A grade must be provided to answer this question")
    @message = message
  end
end
