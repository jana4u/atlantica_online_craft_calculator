require File.join(File.dirname(__FILE__), 'testing_helper')
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'craft_experience_level')
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'craft_experience')

class TestCraftExperience < Test::Unit::TestCase
  def teardown
    AtlanticaOnlineCraftCalculator::CraftExperience.multiplier = nil
  end

  def test_csv_loading_file_with_no_data
    [
      'craft_xp_lvls_empty.csv', # completely empty file
      'craft_xp_lvls_header.csv', # file with header only
    ].each do |csv_file|
      AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_csv(File.join(File.dirname(__FILE__), 'data', csv_file))
      assert_equal [], AtlanticaOnlineCraftCalculator::CraftExperience.levels
      assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.levels.size
    end
  end

  def test_csv_loading_file
    AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_csv(File.join(File.dirname(__FILE__), 'data', 'craft_xp_lvls.csv'))

    assert_equal 3, AtlanticaOnlineCraftCalculator::CraftExperience.levels.size

    assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.levels[0].lvl
    assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.levels[0].xp

    assert_equal 2, AtlanticaOnlineCraftCalculator::CraftExperience.levels[1].lvl
    assert_equal 42, AtlanticaOnlineCraftCalculator::CraftExperience.levels[1].xp

    assert_equal 3, AtlanticaOnlineCraftCalculator::CraftExperience.levels[2].lvl
    assert_equal 104, AtlanticaOnlineCraftCalculator::CraftExperience.levels[2].xp
  end

  def test_setting_levels_from_empty_array
    AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_array([])
    assert_equal [], AtlanticaOnlineCraftCalculator::CraftExperience.levels
    assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.levels.size
  end

  def test_setting_levels_from_array
    [
      [
        { "lvl" => "1", "xp" => "0" },
        { "lvl" => "2", "xp" => "42" },
      ],
      [
        { "lvl" => "2", "xp" => "42" },
        { "lvl" => "1", "xp" => "0" },
      ],
    ].each do |array|

      AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_array(array)

      assert_equal 2, AtlanticaOnlineCraftCalculator::CraftExperience.levels.size

      assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.levels[0].lvl
      assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.levels[0].xp

      assert_equal 2, AtlanticaOnlineCraftCalculator::CraftExperience.levels[1].lvl
      assert_equal 42, AtlanticaOnlineCraftCalculator::CraftExperience.levels[1].xp
    end
  end

  def test_multiplier_setting
    [ nil, 0, "", "0", "abc" ].each do |m|
      AtlanticaOnlineCraftCalculator::CraftExperience.multiplier = m
      assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.multiplier
    end

    [ 2, "2", -2, "-002" ].each do |m|
      AtlanticaOnlineCraftCalculator::CraftExperience.multiplier = m
      assert_equal 2, AtlanticaOnlineCraftCalculator::CraftExperience.multiplier
    end

    [ 0.5, "0.5", "0.50000", "-0.5", -0.50 ].each do |m|
      AtlanticaOnlineCraftCalculator::CraftExperience.multiplier = m
      assert_equal 0.5, AtlanticaOnlineCraftCalculator::CraftExperience.multiplier
    end
  end

  def test_calculation_from_workload
    assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.multiplier

    [nil, "abc", "0", "1.0", "001", 1.0, -1].each do |workload|
      assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    (0..49).each do |workload|
      assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    (50..99).each do |workload|
      assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    AtlanticaOnlineCraftCalculator::CraftExperience.multiplier = 2

    assert_equal 2, AtlanticaOnlineCraftCalculator::CraftExperience.multiplier

    (0..24).each do |workload|
      assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    (25..49).each do |workload|
      assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    (50..74).each do |workload|
      assert_equal 2, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    (75..99).each do |workload|
      assert_equal 3, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    (100..124).each do |workload|
      assert_equal 4, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    AtlanticaOnlineCraftCalculator::CraftExperience.multiplier = 0.5

    assert_equal 0.5, AtlanticaOnlineCraftCalculator::CraftExperience.multiplier

    (0..99).each do |workload|
      assert_equal 0, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end

    (100..199).each do |workload|
      assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.from_workload(workload)
    end
  end

  def test_calculation_level_from_experience
    AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_csv(File.join(File.dirname(__FILE__), 'data', 'craft_xp_lvls.csv'))

    (0..41).each do |experience|
      assert_equal 1, AtlanticaOnlineCraftCalculator::CraftExperience.new(experience).current_level
    end

    (42..103).each do |experience|
      assert_equal 2, AtlanticaOnlineCraftCalculator::CraftExperience.new(experience).current_level
    end

    [104, 105, 100000].each do |experience|
      assert_equal 3, AtlanticaOnlineCraftCalculator::CraftExperience.new(experience).current_level
    end
  end
end
