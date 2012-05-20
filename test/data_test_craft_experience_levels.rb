require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'craft_experience_level')
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'craft_experience')

class DataTestCraftExperienceLevels < Test::Unit::TestCase
  def setup
    AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_csv
  end

  def test_craft_experience_table
    assert_equal 130, AtlanticaOnlineCraftCalculator::CraftExperience.levels.size
    assert_equal 130, AtlanticaOnlineCraftCalculator::CraftExperience.levels.map { |xp_lvl| xp_lvl.lvl }.uniq.size
    assert_equal 130, AtlanticaOnlineCraftCalculator::CraftExperience.levels.map { |xp_lvl| xp_lvl.xp }.uniq.size

    AtlanticaOnlineCraftCalculator::CraftExperience.levels.each do |level|
      assert level.lvl >= 1
      assert level.xp >= 0
    end

    AtlanticaOnlineCraftCalculator::CraftExperience.levels.each_index do |index|
      unless index == 0
        assert AtlanticaOnlineCraftCalculator::CraftExperience.levels[index].lvl >= AtlanticaOnlineCraftCalculator::CraftExperience.levels[index - 1].lvl
        assert AtlanticaOnlineCraftCalculator::CraftExperience.levels[index].xp >= AtlanticaOnlineCraftCalculator::CraftExperience.levels[index - 1].xp
      end
    end
  end
end
