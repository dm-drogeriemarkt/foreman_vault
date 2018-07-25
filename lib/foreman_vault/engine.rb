# frozen_string_literal: true

module ForemanVault
  class Engine < ::Rails::Engine
    engine_name 'foreman_vault'

    config.autoload_paths += Dir["#{config.root}/app/controllers"]
    config.autoload_paths += Dir["#{config.root}/app/helpers"]
    config.autoload_paths += Dir["#{config.root}/app/models"]

    # Add any db migrations
    initializer 'foreman_vault.load_app_instance_data' do |app|
      ForemanVault::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_vault.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_vault do
        requires_foreman '>= 1.20'
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanVault::Engine.load_seed
      end
    end

    initializer 'foreman_vault.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../..', __dir__), 'locale')
      locale_domain = 'foreman_vault'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
