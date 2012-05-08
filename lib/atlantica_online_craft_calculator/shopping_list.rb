module AtlanticaOnlineCraftCalculator
  module ShoppingList
    class Item
      include ListItem
      delegated_methods :unit_price, :price_type

      def total_price
        quantity * unit_price
      end
    end

    class ItemArray < Array
      def total_price
        result = 0

        self.each do |i|
          result += i.total_price
        end

        return result
      end
    end
  end
end
