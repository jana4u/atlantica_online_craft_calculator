module AtlanticaOnlineCraftCalculator
  class Crafter
    if RUBY_VERSION >= "1.9"
      require 'csv'
      FasterCSV = CSV
    else
      require 'rubygems'
      require 'fastercsv'
    end

    def self.load_data_from_csv(data_file = File.join(File.dirname(__FILE__), '../../data', 'craft_experience_levels.csv'))
      csv_data = FasterCSV.read(data_file, :headers => true)

      self.levels = csv_data
    end

    def self.levels=(array)
      @@levels = []

      array.each do |item|
        @@levels << { :lvl => item["lvl"].to_i, :xp => item["xp"].to_i }
      end
    end

    def self.levels
      @@levels || {}
    end

    attr_reader :auto_craft_lvl

    def initialize(auto_craft_lvl)
      @auto_craft_lvl = auto_craft_lvl
    end

    def tick_workload
      100 + (@auto_craft_lvl - 1) * 20
    end

    def ticks_for_workload(workload)
      (workload / tick_workload.to_f).ceil
    end

    def seconds_duration_for_workload(workload)
      (ticks_for_workload(workload) * 5.35).ceil
    end

    def batches_per_hour(workload, hours = 1)
      (hours * 3600 / seconds_duration_for_workload(workload)).floor
    end

    def items_per_hour(workload, batch_size, hours = 1)
      batches_per_hour(workload, hours) * batch_size
    end
  end
end
