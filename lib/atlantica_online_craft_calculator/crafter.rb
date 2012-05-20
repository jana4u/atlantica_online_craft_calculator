module AtlanticaOnlineCraftCalculator
  # When auto-crafting, you will periodically receive some workload each auto-craft tick.
  # The amount of workload you receive is dependent on the level of your expression Auto Craft.
  # You receive 100 for the first level, then 20 for each additional level.
  # Auto-craft ticks occur approximately every 5.35 seconds.
  # http://www.atlanticaonlinewiki.com/index.php?title=Crafting
  class Crafter
    attr_reader :auto_craft_lvl

    # auto-craft level is integer 1 - 120
    def initialize(auto_craft_lvl)
      @auto_craft_lvl = [ [ auto_craft_lvl.to_i, 1 ].max, 120 ].min
    end

    # 100 workload for first auto-craft level, 20 for each additional level per tick
    def tick_workload
      100 + (auto_craft_lvl - 1) * 20
    end

    # how many ticks are needed to finish workload
    def ticks_for_workload(workload)
      (workload / tick_workload.to_f).ceil
    end

    # how many seconds are needed to finish workload
    def seconds_duration_for_workload(workload)
      (ticks_for_workload(workload) * 5.35).ceil
    end
  end
end
