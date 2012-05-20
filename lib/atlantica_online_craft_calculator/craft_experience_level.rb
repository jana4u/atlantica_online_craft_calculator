module AtlanticaOnlineCraftCalculator
  class CraftExperienceLevel
    attr_reader :lvl, :xp

    def initialize(lvl, xp)
      @lvl = lvl.to_i.abs
      @xp = xp.to_i.abs
    end
  end
end
