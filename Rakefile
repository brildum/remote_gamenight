require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  t.pattern = 'tests/**/*.rb'
  t.verbose = true
end

Dir.glob('tasks/*.rake').each { |x| import x }
