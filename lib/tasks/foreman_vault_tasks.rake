# frozen_string_literal: true

require 'rake/testtask'

# Tasks
namespace :foreman_vault do
end

# Tests
namespace :test do
  desc 'Test ForemanVault'
  Rake::TestTask.new(:foreman_vault) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_vault do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_vault) do |task|
        task.patterns = ["#{ForemanVault::Engine.root}/app/**/*.rb",
                         "#{ForemanVault::Engine.root}/lib/**/*.rb",
                         "#{ForemanVault::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_vault'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_vault']

load 'tasks/jenkins.rake'

Rake::Task['jenkins:unit'].enhance ['test:foreman_vault', 'foreman_vault:rubocop'] if Rake::Task.task_defined?(:'jenkins:unit')
