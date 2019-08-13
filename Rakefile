require 'rake/testtask'
require 'resque/tasks'

require './environment'
require './workers'

task default: :test

Rake::TestTask.new do |t|
  t.pattern = 'tests/**/*.rb'
  t.verbose = true
end

Dir.glob('tasks/*.rake').each { |x| import x }

task 'resque:setup' do
  env = Environment.new
  Workers.init!(env.config, env.services)
end
