require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'craft_experience_level')

class TestCraftExperienceLevel < Test::Unit::TestCase
  def test_level_and_xp
    [
      [1, 0],
      [1.0, 0.5],
      [1, nil],
      ["1", "0"],
      ["-1", "00"],
      ["001", "abc"],
    ].each do |params|
      craft_level_xp = AtlanticaOnlineCraftCalculator::CraftExperienceLevel.new(*params)

      assert_equal 1, craft_level_xp.lvl
      assert_equal 0, craft_level_xp.xp
    end
  end
end
