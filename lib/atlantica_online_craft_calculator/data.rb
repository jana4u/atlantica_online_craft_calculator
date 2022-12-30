require 'yaml'

module AtlanticaOnlineCraftCalculator
  module Data
    def self.game_version
      data['game_version']
    end

    def self.updated_on
      data['updated_on']
    end

    def self.data
      @data ||= YAML.safe_load_file(
        File.join(File.dirname(__FILE__), '../../data/info.yml'),
        permitted_classes: [Date]
      )
    end
  end
end
