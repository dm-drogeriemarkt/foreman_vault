# frozen_string_literal: true

require File.expand_path('lib/foreman_vault/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'foreman_vault'
  s.version     = ForemanVault::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['dm-drogerie markt GmbH & Co. KG']
  s.email       = ['opensource@dm.de']
  s.homepage    = 'https://github.com/dm-drogeriemarkt-de/foreman_vault'
  s.summary     = 'Adds support for using credentials from Hashicorp Vault'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rubocop'
end
