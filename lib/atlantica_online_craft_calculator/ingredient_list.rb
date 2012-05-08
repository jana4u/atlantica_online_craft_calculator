module AtlanticaOnlineCraftCalculator
  module IngredientList
    class Item < ShoppingList::Item
      delegated_methods :ingredient_items
    end

    class ItemArray < ShoppingList::ItemArray
    end
  end
end
