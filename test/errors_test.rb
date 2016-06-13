require_relative 'test_helper'
require_relative '../lib/errors'

class ErrorsTest < Minitest::Test

  def test_it_has_an_unknown_data_error
    assert_raises(UnknownDataError) do
      raise UnknownDataError
    end
  end

  def test_unknown_data_error_can_have_a_custom_message
    unknown_data = UnknownDataError.new("No data available")
    assert_equal "No data available", unknown_data.message
  end

  def test_unknown_data_error_has_a_default_message
    unknown_data = UnknownDataError.new
    assert_equal "Data unavailable", unknown_data.message
  end

  def test_it_has_an_unknown_race_error
    assert_raises(UnknownRaceError) do
      raise UnknownRaceError
    end
  end

  def test_unknown_race_error_can_have_a_custom_message
    unknown_race = UnknownRaceError.new("So sorry")
    assert_equal "So sorry", unknown_race.message
  end

  def test_unknown_race_error_has_a_default_message
    unknown_race = UnknownRaceError.new
    assert_equal "Data unavailable", unknown_race.message
  end

  def test_it_can_raise_an_insufficient_information_error
    assert_raises(InsufficientInformationError) do
      raise InsufficientInformationError
    end
  end

  def test_insufficient_information_error_can_have_a_custom_message
    insufficient_info = InsufficientInformationError.new("Nope")
    assert_equal "Nope", insufficient_info.message
  end

  def test_insufficient_information_error_has_a_default_message
    insufficient_info = InsufficientInformationError.new
    assert_equal "A grade must be provided to answer this question", insufficient_info.message
  end

end
