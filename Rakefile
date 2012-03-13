require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :anonym, :tokens do |t, args|
  replace = args[:tokens].split(" ").map do |token|
    from, to = token.split(":")
    "s/#{from}/#{to}/g"
  end

  `find -E . -regex '^.+\.(rb|yml)$' -exec sed -i "" "#{replace.join(";")}" {} \\;`
end

task :deanonym, :tokens do |t, args|
  replace = args[:tokens].split(" ").map do |token|
    from, to = token.split(":")
    "s/#{to}/#{from}/g"
  end

  `find -E . -regex '^.+\.(rb|yml)$' -exec sed -i "" "#{replace.join(";")}" {} \\;`
end
