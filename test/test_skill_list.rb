require File.join(File.dirname(__FILE__), 'testing_helper')
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'craft_experience')
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator', 'skill_list')

class TestSkillList < Test::Unit::TestCase
  def test_item_creating
    [
      [1, 100],
      [1.0, 100.0],
      [-1, -100],
      ["1.0", "0100"],
      ["001", "100.00"],
    ].each do |params|
      item = AtlanticaOnlineCraftCalculator::SkillList::Item.new("Skill", *params)

      assert_equal "Skill", item.name
      assert_equal 1, item.lvl
      assert_equal 100, item.workload
    end
  end

  def test_item_workload_setting
    item = AtlanticaOnlineCraftCalculator::SkillList::Item.new("Skill", 1, 100)

    [ 200, -200.0, "200.0"].each do |wl|
      item.workload = wl
      assert_equal 200, item.workload
    end
  end

  def test_item_lvl_setting
    item = AtlanticaOnlineCraftCalculator::SkillList::Item.new("Skill", 1, 100)

    [ 5, -5.0, "5.0"].each do |lvl|
      item.lvl = lvl
      assert_equal 5, item.lvl
    end
  end

  def test_item_craft_xp_gained
    item = AtlanticaOnlineCraftCalculator::SkillList::Item.new("Skill", 1, 100)

    assert_equal 2, item.craft_xp_gained
  end

  def test_array_find_by_name_empty_arrray
    array = AtlanticaOnlineCraftCalculator::SkillList::ItemArray.new

    assert_nil array.find_by_name("Skill")
  end

  def test_array_find_by_name_arrray_with_only_searched_item
    name = "Skill"
    array = AtlanticaOnlineCraftCalculator::SkillList::ItemArray.new

    assert_nil array.find_by_name(name)

    item = AtlanticaOnlineCraftCalculator::SkillList::Item.new(name, 1, 100)
    array << item

    assert_equal item, array.find_by_name(name)
  end

  def test_array_find_by_name_arrray_with_multiple_items
    name = "Skill"
    array = AtlanticaOnlineCraftCalculator::SkillList::ItemArray.new

    assert_nil array.find_by_name(name)

    item1 = AtlanticaOnlineCraftCalculator::SkillList::Item.new(name + "1", 1, 100)
    array << item1

    assert_nil array.find_by_name(name)

    item = AtlanticaOnlineCraftCalculator::SkillList::Item.new(name, 1, 100)
    array << item

    assert_equal item, array.find_by_name(name)

    item2 = AtlanticaOnlineCraftCalculator::SkillList::Item.new(name + "2", 1, 100)
    array << item2

    assert_equal item, array.find_by_name(name)
  end
end
