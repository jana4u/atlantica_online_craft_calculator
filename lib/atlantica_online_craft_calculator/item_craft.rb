module AtlanticaOnlineCraftCalculator
  class ItemCraft
    def self.remove_leftovers_from_lists(craft_list, shopping_list, leftovers)
      leftovers.each do |leftover|
        if leftover.more_than_batch? && (cl_item = craft_list.detect { |i| i.name == leftover.name })
          leftover.ingredient_list.each do |li|
            existing_leftover = leftovers.detect { |l| l.item == li.item }
            leftover_quantity = li.quantity * leftover.whole_batches
            if existing_leftover
              existing_leftover.quantity += leftover_quantity
            else
              leftovers << LeftoverList::Item.new(li.item, leftover_quantity)
            end
          end

          do_not_craft_quantity = leftover.whole_batches * leftover.batch_size
          cl_item.quantity -= do_not_craft_quantity
          leftover.quantity -= do_not_craft_quantity
        elsif sl_item = shopping_list.detect { |i| i.name == leftover.name }
          sl_item.quantity -= leftover.quantity
          leftover.quantity = 0
        end
      end

      leftovers = leftovers.reject { |l| l.quantity.zero? }

      while leftovers.detect { |l| l.more_than_batch? } do
        craft_list, shopping_list, leftovers = remove_leftovers_from_lists(craft_list, shopping_list, leftovers)
      end

      return craft_list, shopping_list, leftovers
    end

    attr_reader :item, :requested_quantity

    def initialize(item, requested_quantity = nil)
      @item = item
      @requested_quantity = requested_quantity || item.batch_size
    end

    [
      :total_workload,
      :total_workload_per_skill,
      :total_craft_xp_gained,
      :total_craft_xp_gained_per_skill,
      :skills,
    ].each do |method_name|
      define_method method_name do
        craft_list.send(method_name)
      end
    end

    [
      :total_price,
    ].each do |method_name|
      define_method method_name do
        shopping_list.send(method_name)
      end
    end

    def quantity
      @quantity ||= batches * item.batch_size
    end

    def batches
      @batches ||= (requested_quantity / item.batch_size.to_f).ceil.to_i
    end

    def price
      item.unit_price * quantity
    end

    def workload
      @workload ||= batches * @item.workload
    end

    def craft_xp_gained
      @craft_xp_gained ||= workload / CRAFT_XP_TO_WORKLOAD_RATIO
    end

    def ingredient_list
      return @ingredient_list if defined?(@ingredient_list)

      @ingredient_list = IngredientList::ItemArray.new

      if item.craftable?
        item.ingredient_list.each do |ingredient|
          @ingredient_list << IngredientList::Item.new(ingredient.item, ingredient.quantity * batches)
        end
      end

      return @ingredient_list
    end

    def item_with_raw_craft_tree
      return @item_with_raw_craft_tree if defined?(@item_with_raw_craft_tree)

      list = CraftTree::ItemArray.new

      if item.crafting_is_cheaper?
        item.ingredient_list.each do |ingredient|
          list << self.class.new(ingredient.item, ingredient.quantity * batches).item_with_raw_craft_tree
        end
        item_quantity = quantity
      else
        item_quantity = requested_quantity
      end

      @item_with_raw_craft_tree = CraftTree::Item.new(item, requested_quantity, item_quantity, list)

      return @item_with_raw_craft_tree
    end

    def craft_list
      @craft_list || create_lists[0]
    end

    def shopping_list
      @shopping_list || create_lists[1]
    end

    def leftovers
      @leftovers || create_lists[2]
    end

    def raw_craft_list
      item_with_raw_craft_tree.ordered_craft_list
    end

    def raw_shopping_list
      item_with_raw_craft_tree.shopping_list
    end

    def raw_leftovers
      item_with_raw_craft_tree.leftovers.reverse
    end

    def craft_tree_leftovers
      @craft_tree_leftovers ||= item_with_raw_craft_tree.leftovers
    end

    private

    def create_lists
      @craft_list, @shopping_list, @leftovers =
        self.class.remove_leftovers_from_lists(
        raw_craft_list,
        raw_shopping_list,
        raw_leftovers
      )
    end
  end
end
