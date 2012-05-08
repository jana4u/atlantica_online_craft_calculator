module AtlanticaOnlineCraftCalculator
  module CraftTree
    class Item
      include ListItem
      delegated_methods :unit_price, :price_type
      attr_reader :requested_quantity, :ingredients_craft_tree

      def initialize(item, requested_quantity, quantity, ingredients_craft_tree)
        @item = item
        @requested_quantity = requested_quantity
        @quantity = quantity
        @ingredients_craft_tree = ingredients_craft_tree
      end

      def crafted?
        !ingredients_craft_tree.empty?
      end

      def total_price
        unit_price * quantity
      end

      def leftover_quantity
        quantity - requested_quantity
      end

      def leftovers
        list = LeftoverList::ItemArray.new

        craft_list.each do |cl_item|
          list << LeftoverList::Item.new(cl_item.item, 0)
        end

        if leftover_quantity > 0
          list.detect { |l| l.name == name }.quantity += leftover_quantity
        end

        ingredients_craft_tree.each do |i|
          i.leftovers.each do |leftover|
            list.detect { |l| l.name == leftover.name }.quantity += leftover.quantity
          end
        end

        return list.reject { |i| i.quantity.zero? }
      end

      def shopping_list
        list = ShoppingList::ItemArray.new

        if crafted?
          ingredients_craft_tree.each do |ingredient|
            ingredient.shopping_list.each do |isl_item|
              if existing_sl_item = list.detect { |l| l.name == isl_item.name }
                existing_sl_item.quantity += isl_item.quantity
              else
                list << isl_item
              end
            end
          end
        else
          list << ShoppingList::Item.new(item, requested_quantity)
        end

        return list
      end

      def craft_list
        list = CraftList::ItemArray.new

        if crafted?
          list << CraftList::Item.new(item, quantity)

          ingredients_craft_tree.each do |ingredient|
            ingredient.craft_list.each do |icl_item|
              if existing_cl_item = list.detect { |l| l.name == icl_item.name }
                icl_item.quantity += existing_cl_item.quantity
                list.delete(existing_cl_item)
              end

              list << icl_item
            end
          end
        end

        return list
      end
    end

    class ItemArray < Array
    end
  end
end
