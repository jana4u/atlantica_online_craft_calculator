module AtlanticaOnlineCraftCalculator
  module SkillList
    class Item
      attr_reader :name
      attr_accessor :lvl, :workload

      def initialize(name, lvl, workload)
        @name = name
        @lvl = lvl
        @workload = workload
      end

      def craft_xp_gained
        workload / CRAFT_XP_TO_WORKLOAD_RATIO
      end
    end

    class ItemArray < Array
      def find(skill_name)
        detect { |s| s.name == skill_name }
      end
    end
  end
end
