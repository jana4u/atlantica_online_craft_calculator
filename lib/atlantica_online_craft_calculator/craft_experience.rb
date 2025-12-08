require 'csv'

module AtlanticaOnlineCraftCalculator
  class CraftExperience
    def self.load_levels_from_csv(data_file = File.join(File.dirname(__FILE__), '../../data', 'craft_experience_levels.csv'))
      csv_data = CSV.read(data_file, :headers => true)

      self.load_levels_from_array(csv_data)
    end

    def self.load_levels_from_array(array)
      levels = []

      array.each do |item|
        levels << CraftExperienceLevel.new(item["lvl"], item["xp"])
      end

      @levels = levels.sort_by { |level| level.lvl }
    end

    def self.levels
      @levels ||= []
    end

    def self.multiplier
      @multiplier ||= 1
    end

    def self.multiplier=(value)
      @multiplier = value.to_f.abs

      if @multiplier.zero?
        @multiplier = nil
      end
    end

    def self.from_workload(workload)
      (workload.to_i.abs * multiplier / 50).floor
    end

    attr_reader :experience, :skill

    def initialize(experience, skill = nil)
      @experience = experience
      @skill = skill
    end

    def craftable_items_for_skill
      @craftable_items_for_skill ||= Item.craftable_items_for_skill_ordered_by_skill_lvl(skill)
    end

    def skill_maxed?
      craftable_items_for_skill.last.skill_lvl <= current_level
    end

    def current_craft_experience_level
      @current_craft_experience_level ||= self.class.levels.reverse.detect { |l| experience >= l.xp }
    end

    def current_level_experience
      current_craft_experience_level.xp
    end

    def current_level
      current_craft_experience_level.lvl
    end

    def current_best_craftable_items
      item_lvl = craftable_items_for_skill.map { |i| i.skill_lvl }.select { |i| current_level >= i }.max
      craftable_items_for_skill.select { |i| item_lvl == i.skill_lvl }
    end

    def next_craft_experience_level
      @next_craft_experience_level ||= self.class.levels.detect { |l| experience < l.xp }
    end

    def next_level_experience
      next_craft_experience_level.xp
    end

    def next_level
      next_craft_experience_level.lvl
    end

    def next_item_level
      craftable_items_for_skill.map { |i| i.skill_lvl }.select { |i| current_level < i }.min
    end

    def next_craftable_items
      craftable_items_for_skill.select { |i| next_item_level == i.skill_lvl }
    end

    def next_item_craft_experience_level
      @next_item_craft_experience_level ||= self.class.levels.detect { |l| next_item_level == l.lvl }
    end

    def next_item_level_experience
      next_item_craft_experience_level.xp
    end

    def maximum_experience_reached?
      experience >= self.class.levels.last.xp
    end

    def experience_needed_for_next_level
      next_level_experience - experience
    end

    def experience_needed_for_next_item_level
      next_item_level_experience - experience
    end

    def percentage_of_next_level
      (experience - current_level_experience) * 100 / (next_level_experience - current_level_experience)
    end

    def percentage_of_next_item_level
      (experience - current_level_experience) * 100 / (next_item_level_experience - current_level_experience)
    end
  end
end
