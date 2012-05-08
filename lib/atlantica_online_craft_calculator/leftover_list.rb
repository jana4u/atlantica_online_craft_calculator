module AtlanticaOnlineCraftCalculator
  module LeftoverList
    class Item
      include ListItem
      delegated_methods :ingredients, :batch_size, :ingredient_list

      def whole_batches
        (quantity / batch_size.to_f).floor.to_i
      end

      def more_than_batch?
        whole_batches > 0
      end
    end

    class ItemArray < Array
    end
  end
end
