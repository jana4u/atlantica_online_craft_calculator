require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/atlantica_online_craft_calculator')

class DataTestItems < Test::Unit::TestCase
  def setup
    AtlanticaOnlineCraftCalculator::Item.load_data_from_yaml
  end

  def test_lists_of_items
    assert_equal 2231, AtlanticaOnlineCraftCalculator::Item.all.size
    assert AtlanticaOnlineCraftCalculator::Item.all.size > 0
    assert AtlanticaOnlineCraftCalculator::Item.ordered_items.size > 0
    assert_equal AtlanticaOnlineCraftCalculator::Item.all.size,
      AtlanticaOnlineCraftCalculator::Item.ordered_items.size

    assert AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items.size > 0
    assert AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items.size < AtlanticaOnlineCraftCalculator::Item.all.size

    assert AtlanticaOnlineCraftCalculator::Item.ordered_ingredient_items.size > 0
    assert AtlanticaOnlineCraftCalculator::Item.ordered_ingredient_items.size < AtlanticaOnlineCraftCalculator::Item.all.size
  end

  def test_items_return_basic_data
    AtlanticaOnlineCraftCalculator::Item.ordered_items.each do |item|
      assert_not_nil item.name
      assert_not_nil item.unit_price
      assert_not_nil item.price_type
    end
  end

  def test_craftable_items_return_basic_data
    AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items.each do |item|
      assert_not_nil item.workload
      assert_not_nil item.skill
      assert_not_nil item.skill_lvl

      assert_not_nil item.craft_xp_gained_per_batch
      assert_not_nil item.craft_xp_gained_per_item

      [
        AtlanticaOnlineCraftCalculator::Crafter.new(1),
        AtlanticaOnlineCraftCalculator::Crafter.new(120),
      ].each do |crafter|
        assert_not_nil crafter.seconds_duration_for_workload(item.workload)
      end

      if item.direct_price
        assert_not_nil item.money_saved_by_crafting
        assert_not_nil item.crafting_is_more_expensive?
      else
        assert_nil item.money_saved_by_crafting
      end
    end
  end

  def test_craftable_items_return_ingredients
    AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items.each do |item|
      assert item.ordered_ingredient_items.size > 0
    end
  end

  def test_item_skills
    assert_equal 39, AtlanticaOnlineCraftCalculator::Item.ordered_item_skills.size

    items_size = 0
    AtlanticaOnlineCraftCalculator::Item.ordered_item_skills.each do |skill|
      assert_not_nil skill

      items_by_skill = AtlanticaOnlineCraftCalculator::Item.craftable_items_for_skill_ordered_by_skill_lvl(skill)

      items_size += items_by_skill.size

      items_by_skill.each do |item|
        assert_not_nil item.name
        assert_not_nil item.skill_lvl
      end
    end

    assert_equal AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items.size, items_size
  end

  def test_custom_prices
    item_names = ["Ashen Crystal", "Ashen Jewel", "Multi-Hued Jewel"]

    old_prices = {}

    item_names.each do |item_name|
      item = AtlanticaOnlineCraftCalculator::Item.find(item_name)
      assert_not_nil item
      assert_not_nil item.name
      assert_not_nil item.unit_price
      assert_not_nil item.price_type
      old_prices[item.name] = item.unit_price
    end

    AtlanticaOnlineCraftCalculator::Item.load_data_from_yaml({ "Ashen Crystal" => 5400 })

    item_names.each do |item_name|
      item = AtlanticaOnlineCraftCalculator::Item.find(item_name)
      assert_not_nil item
      assert_not_nil item.name
      assert_not_nil item.unit_price
      assert_not_nil item.price_type
      assert item.unit_price < old_prices[item.name]
    end
  end

  def item_with_raw_craft_tree_assertions(item)
    assert_not_nil item.name
    assert_not_nil item.requested_quantity
    assert_not_nil item.quantity
    assert_not_nil item.price_type
    assert item.quantity >= item.requested_quantity

    item.ingredients_craft_tree.each do |i|
      item_with_raw_craft_tree_assertions(i)
    end
  end

  def test_item_craft
    crafter = AtlanticaOnlineCraftCalculator::Crafter.new(120)

    AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items.each do |item|
      item_craft = AtlanticaOnlineCraftCalculator::ItemCraft.new(item, 5)
      assert_not_nil item_craft.requested_quantity
      assert_not_nil item_craft.quantity
      assert item_craft.quantity >= item_craft.requested_quantity

      assert_not_nil item_craft.total_price

      assert_not_nil item_craft.workload
      assert_not_nil item_craft.total_workload

      if item.crafting_is_cheaper?
        assert item_craft.total_workload >= item_craft.workload
      else
        assert item_craft.total_workload < item_craft.workload
        assert_equal 0, item_craft.total_workload
      end

      assert_not_nil item_craft.craft_xp_gained
      assert_not_nil item_craft.total_craft_xp_gained

      assert_not_nil crafter.seconds_duration_for_workload(item_craft.total_workload)

      item_craft.skills.each do |skill|
        assert_not_nil skill.name
        assert_not_nil skill.workload
        assert_not_nil skill.craft_xp_gained
      end

      assert item_craft.shopping_list.size > 0

      item_craft.shopping_list.each do |shopping_list_item|
        assert_not_nil shopping_list_item.name
        assert_not_nil shopping_list_item.quantity
      end

      if item.crafting_is_cheaper?
        assert item_craft.craft_list.size > 0

        item_craft.craft_list.each do |craft_list_item|
          assert_not_nil craft_list_item.name
          assert_not_nil craft_list_item.quantity
          assert_not_nil craft_list_item.total_craft_xp_gained
          assert_not_nil craft_list_item.total_price
        end

        item_craft.leftovers.each do |leftover|
          assert_not_nil leftover.name
          assert_not_nil leftover.quantity
        end

        item_with_raw_craft_tree_assertions(item_craft.item_with_raw_craft_tree)
      else
        assert_equal 0, item_craft.craft_list.size
        assert_equal 0, item_craft.leftovers.size
      end

    end
  end
end
