module AtlanticaOnlineCraftCalculator
  class Item
    def self.load_data_from_yaml(data_file = File.join(File.dirname(__FILE__), '../../data', 'items.yml'))
      require 'yaml'

      yaml_data = YAML.safe_load_file(data_file, freeze: true)

      self.all = yaml_data
    end

    def self.configure_custom_prices(custom_prices)
      custom_prices.each do |item_name, price|
        if item = all[item_name]
          item.market_price = price
        end
      end
    end

    def self.configure_items_with_crafting_disabled(items_with_crafting_disabled)
      items_with_crafting_disabled.each do |item_name|
        if (item = all[item_name]) && (item.fixed_price || item.market_price)
          item.crafting_disabled = true
        end
      end
    end

    def self.all=(hash)
      @all = {}

      hash.each do |item_name, item_data|
        @all[item_name] = new(item_data.merge({ "name" => item_name}))
      end
    end

    def self.all
      @all || {}
    end

    def self.find(item_name)
      item = all[item_name]

      raise InvalidItem, "No item '#{item_name}' found" unless item

      return item
    end

    def self.items
      all.values
    end

    def self.ordered_items
      items.sort_by { |i| i.name_for_sort }
    end

    def self.ordered_craftable_items
      ordered_items.select{ |i| i.craftable? }
    end

    def self.craftable_items_for_skill_ordered_by_skill_lvl(skill)
      ordered_craftable_items.select{ |i| i.skill == skill }.sort_by { |i| i.skill_lvl_and_name_for_sort }
    end

    def self.ordered_ingredient_items
      ingredient_names = []

      items.each do |item|
        if item.craftable?
          ingredient_names += item.ingredients.keys
        end
      end

      ingredient_names = ingredient_names.uniq

      ingredients = []

      ingredient_names.each do |ingredient_name|
        ingredients << find(ingredient_name)
      end

      ingredients.sort_by { |i| i.name_for_sort }
    end

    def self.item_skills
      all.values.map { |i| i.skill }.compact.uniq
    end

    def self.ordered_item_skills
      item_skills.sort
    end

    def initialize(hash)
      @data = hash
    end

    [
      :name,
      :ingredients,
      :workload,
      :skill,
      :skill_lvl,
      :market_price,
      :fixed_price,
      :crafting_disabled,
    ].each do |method_name|
      define_method method_name do
        @data[method_name.to_s]
      end
    end

    [
      :market_price,
      :crafting_disabled,
    ].each do |method_name|
      define_method "#{method_name}=" do |value|
        @data[method_name.to_s] = value
      end
    end

    def name_for_sort
      name.gsub("[I]", "1").gsub("[II]", "2").gsub("[III]", "3").gsub("[IV]", "4").gsub("[V]", "5").gsub("[VI]", "6")
    end

    def skill_lvl_and_name_for_sort
      "#{skill_lvl.to_s.rjust(3, "0")} #{name_for_sort}"
    end

    def batch_size
      @data["batch_size"] || 1
    end

    def craftable?
      !ingredients.nil? && !crafting_disabled
    end

    def crafting_is_cheaper?
      craftable? && (!direct_price || craft_price < direct_price)
    end

    def crafting_is_more_expensive?
      craftable? && direct_price && craft_price > direct_price
    end

    def money_saved_by_crafting
      return nil if !craftable? || !direct_price
      direct_price - craft_price
    end

    def ingredient_list
      return @ingredient_list if defined?(@ingredient_list)

      @ingredient_list = IngredientList::ItemArray.new

      if craftable?
        ingredients.each do |ingredient_name, ingredient_quantity|
          @ingredient_list << IngredientList::Item.new(self.class.find(ingredient_name), ingredient_quantity)
        end
      end

      return @ingredient_list
    end

    def ordered_ingredient_items
      ingredient_items.sort_by { |i| i.name_for_sort }
    end

    def ingredient_items
      list = []

      ingredient_list.each do |ingredient_item|
        list << ingredient_item.item
        list += ingredient_item.ingredient_items
      end

      return list.uniq
    end

    def direct_price
      send(direct_price_type)
    end

    def batch_craft_price
      return @batch_craft_price if defined?(@batch_craft_price)

      if craftable?
        result = ingredient_list.total_price
      else
        result = nil
      end

      @batch_craft_price = result
    end

    def craft_price
      if batch_craft_price
        batch_craft_price / batch_size
      else
        nil
      end
    end

    def price_type
      if crafting_is_cheaper?
        :craft_price
      else
        direct_price_type
      end
    end

    def direct_price_type
      if market_price && (!fixed_price || market_price < fixed_price)
        :market_price
      else
        :fixed_price
      end
    end

    def unit_price
      return send(price_type)
    end

    def craft_xp_gained_per_batch
      CraftExperience.from_workload(workload)
    end

    def craft_xp_gained_per_item
      craft_xp_gained_per_batch / batch_size.to_f
    end
  end

  class InvalidItem < RuntimeError
  end
end
