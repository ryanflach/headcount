class UnknownDataError < StandardError
  attr_reader :message

  def initialize(message = "Data unavailable")
    @message = message
  end
end

class UnknownRaceError < UnknownDataError
end
