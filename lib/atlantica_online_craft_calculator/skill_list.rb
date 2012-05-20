module AtlanticaOnlineCraftCalculator
  module SkillList
    class Item
      attr_reader :name, :lvl, :workload

      def initialize(name, lvl, workload)
        @name = name
        self.lvl = lvl
        self.workload = workload
      end

      def lvl=(lvl)
        @lvl = lvl.to_i.abs
      end

      def workload=(workload)
        @workload = workload.to_i.abs
      end

      def craft_xp_gained
        CraftExperience.from_workload(workload)
      end
    end

    class ItemArray < Array
      def find_by_name(name)
        detect { |s| s.name == name }
      end
    end
  end
end
