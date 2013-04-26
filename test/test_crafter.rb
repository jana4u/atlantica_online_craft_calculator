require File.join(File.dirname(__FILE__), 'testing_helper')
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'crafter')

class TestCrafter < Test::Unit::TestCase
  def test_auto_craft_lvl_range
    {
      "" => 1,
      "-5" => 1,
      "x" => 1,
      "2" => 2,
      "100 " => 100,
      "120" => 120,
      "121" => 120,
    }.each do |auto_craft_lvl_input, auto_craft_lvl_output|
      assert_equal auto_craft_lvl_output, AtlanticaOnlineCraftCalculator::Crafter.new(auto_craft_lvl_input).auto_craft_lvl
    end
  end

  def test_tick_workload
    {
      1 => 100,
      2 => 120,
      100 => 2080,
      120 => 2480,
    }.each do |auto_craft_lvl, tick_workload|
      assert_equal tick_workload, AtlanticaOnlineCraftCalculator::Crafter.new(auto_craft_lvl).tick_workload
    end
  end

  def test_ticks_and_seconds_duration_for_workload
    crafter = AtlanticaOnlineCraftCalculator::Crafter.new(1)

    assert_equal 100, crafter.tick_workload

    assert_equal 0, crafter.ticks_for_workload(0)
    assert_equal 0, crafter.seconds_duration_for_workload(0)

    (1..100).each do |workload|
      assert_equal 1, crafter.ticks_for_workload(workload)
      assert_equal 6, crafter.seconds_duration_for_workload(workload)
    end

    (101..200).each do |workload|
      assert_equal 2, crafter.ticks_for_workload(workload)
      assert_equal 11, crafter.seconds_duration_for_workload(workload)
    end

    assert_equal 100, crafter.ticks_for_workload(10000)
    assert_equal 535, crafter.seconds_duration_for_workload(10000)
  end
end
