# frozen_string_literal: true

module ForemanVault
  class Engine < ::Rails::Engine
    engine_name 'foreman_vault'

    config.autoload_paths += Dir["#{config.root}/app/controllers"]
    config.autoload_paths += Dir["#{config.root}/app/helpers"]
    config.autoload_paths += Dir["#{config.root}/app/models"]
    config.autoload_paths += Dir["#{config.root}/app/services"]

    # Add any db migrations
    initializer 'foreman_vault.load_app_instance_data' do |app|
      ForemanVault::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_vault.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_vault do
        requires_foreman '>= 1.20'

        # Add permissions
        security_block :foreman_vault do
          permission :view_vault_connections,     { vault_connections: [:index] },         resource_type: 'VaultConnection'
          permission :create_vault_connections,   { vault_connections: [:new, :create] },  resource_type: 'VaultConnection'
          permission :edit_vault_connections,     { vault_connections: [:edit, :update] }, resource_type: 'VaultConnection'
          permission :destroy_vault_connections,  { vault_connections: [:destroy] },       resource_type: 'VaultConnection'
        end

        # add menu entry
        menu :top_menu, :vault_connections, url_hash: { controller: :vault_connections, action: :index },
                                            caption: N_('Vault connections'),
                                            parent: :infrastructure_menu
      end
    end

    config.to_prepare do
      begin
        Foreman::Renderer::Scope::Base.include(ForemanVault::Renderer::Scope::Macros::VaultSecrets)
        Foreman::Renderer.configure { |c| c.allowed_generic_helpers += [:vault_secret] }
      rescue StandardError => e
        Rails.logger.warn "ForemanVault: skipping engine hook (#{e})"
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
