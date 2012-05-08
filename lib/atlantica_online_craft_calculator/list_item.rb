module AtlanticaOnlineCraftCalculator
  module ListItem
    def self.included(base)
      base.send(:attr_accessor, :quantity)
      base.send(:attr_reader, :item)
      base.extend(ClassMethods)
      base.send(:delegated_methods, :name)
    end

    def initialize(item, quantity)
      @item = item
      @quantity = quantity
    end

    module ClassMethods
      def delegated_methods(*args)
        args.each do |method_name|
          define_method method_name do
            @item && @item.send(method_name)
          end
        end
      end
    end
  end
end
