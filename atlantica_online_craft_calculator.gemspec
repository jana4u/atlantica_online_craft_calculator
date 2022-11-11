# -*- encoding: utf-8 -*-
require File.expand_path('../lib/atlantica_online_craft_calculator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jana Dvořáková (Jana4U)"]
  gem.email         = ["jana4u@seznam.cz"]
  gem.description   = %q{Craft Calculator for MMORPG Atlantica Online.}
  gem.summary       = %q{Craft Calculator for MMORPG Atlantica Online.}
  gem.homepage      = "https://github.com/jana4u/atlantica_online_craft_calculator"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "atlantica_online_craft_calculator"
  gem.require_paths = ["lib"]
  gem.version       = AtlanticaOnlineCraftCalculator::VERSION
end
