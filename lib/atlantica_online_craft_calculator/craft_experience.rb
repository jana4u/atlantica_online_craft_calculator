module AtlanticaOnlineCraftCalculator
  class CraftExperience
    if RUBY_VERSION >= "1.9"
      require 'csv'
      FasterCSV = CSV
    else
      require 'rubygems'
      require 'fastercsv'
    end

    def self.load_levels_from_csv(data_file = File.join(File.dirname(__FILE__), '../../data', 'craft_experience_levels.csv'))
      csv_data = FasterCSV.read(data_file, :headers => true)

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
  end
end
