require 'rspec/core/rake_task'
require 'foodcritic'

::FoodCritic::Rake::LintTask.new
::RSpec::Core::RakeTask.new(:rspec)

task default: %i[foodcritic rspec]
