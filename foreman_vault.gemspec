# frozen_string_literal: true

require File.expand_path('lib/foreman_vault/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'foreman_vault'
  s.version     = ForemanVault::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['dmTECH GmbH']
  s.email       = ['opensource@dm.de']
  s.homepage    = 'https://github.com/dm-drogeriemarkt/foreman_vault'
  s.summary     = 'Adds support for using credentials from Hashicorp Vault'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'vault', '~> 0.1'

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rubocop', '0.54.0'
end
