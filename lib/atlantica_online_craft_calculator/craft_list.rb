module AtlanticaOnlineCraftCalculator
  module CraftList
    class Item
      include ListItem
      delegated_methods :unit_price, :ingredients, :batch_size, :workload, :skill, :skill_lvl

      def batches
        quantity / batch_size
      end

      def total_price
        unit_price * quantity
      end

      def total_workload
        batches * workload
      end

      def total_craft_xp_gained
        total_workload / CRAFT_XP_TO_WORKLOAD_RATIO
      end
    end

    class ItemArray < Array
      def skills
        result = SkillList::ItemArray.new

        self.each do |i|
          if skill = result.find(i.skill)
            skill.workload += i.total_workload
            if i.skill_lvl > skill.lvl
              skill.lvl = i.skill_lvl
            end
          else
            result << SkillList::Item.new(i.skill, i.skill_lvl, i.total_workload)
          end
        end

        return result.sort_by { |s| s.name }
      end

      def total_workload
        result = 0

        self.each do |i|
          result += i.total_workload
        end

        return result
      end

      def total_craft_xp_gained
        total_workload / CRAFT_XP_TO_WORKLOAD_RATIO
      end
    end
  end
end
