require_relative 'test_helper'
require_relative '../lib/errors'

class ErrorsTest < Minitest::Test
  include Errors

  def test_it_has_an_unknown_data_error
    unknown_data = UnknownDataError.new
    assert_raises(UnknownDataError) do
      raise unknown_data
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
    unknown_race = UnknownRaceError.new
    assert_raises(UnknownRaceError) do
      raise unknown_race
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

end
