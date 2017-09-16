require 'bundler'
require 'rspec/core/rake_task'
require 'yard'
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = true
  t.rspec_opts = '--tty --color'
end

YARD::Rake::YardocTask.new
