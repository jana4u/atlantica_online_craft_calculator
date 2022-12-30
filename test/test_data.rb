require_relative 'testing_helper'
require_relative '../lib/atlantica_online_craft_calculator/data'

class TestCrafter < Test::Unit::TestCase
  def test_game_version
    assert AtlanticaOnlineCraftCalculator::Data.game_version
    assert AtlanticaOnlineCraftCalculator::Data.game_version > 0
  end

  def test_updated_on
    assert AtlanticaOnlineCraftCalculator::Data.updated_on
    assert AtlanticaOnlineCraftCalculator::Data.updated_on <= Date.today
  end
end
