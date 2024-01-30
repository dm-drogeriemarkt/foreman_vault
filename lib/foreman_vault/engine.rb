# frozen_string_literal: true

require 'vault'

module ForemanVault
  class Engine < ::Rails::Engine
    engine_name 'foreman_vault'

    config.autoload_paths += Dir["#{config.root}/app/controllers"]
    config.autoload_paths += Dir["#{config.root}/app/models"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/lib"]
    config.autoload_paths += Dir["#{config.root}/app/jobs"]

    # Add any db migrations
    initializer 'foreman_vault.load_app_instance_data' do |app|
      ForemanVault::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_vault.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_vault do
        requires_foreman '>= 3.1'

        apipie_documented_controllers ["#{ForemanVault::Engine.root}/app/controllers/api/v2/*.rb"]

        # Add permissions
        security_block :foreman_vault do
          permission :view_vault_connections,     { vault_connections: [:index, :show],
                                                    'api/v2/vault_connections': [:index, :show] }, resource_type: 'VaultConnection'
          permission :create_vault_connections,   { vault_connections: [:new, :create],
                                                    'api/v2/vault_connections': [:create] }, resource_type: 'VaultConnection'
          permission :edit_vault_connections,     { vault_connections: [:edit, :update],
                                                    'api/v2/vault_connections': [:update] }, resource_type: 'VaultConnection'
          permission :destroy_vault_connections,  { vault_connections: [:destroy],
                                                    'api/v2/vault_connections': [:destroy] }, resource_type: 'VaultConnection'
        end

        settings do
          category(:vault, N_('Vault')) do
            setting('vault_connection',
                    full_name: N_('Default Vault connection'),
                    type: :string,
                    description: N_('Default Vault Connection that can be override using parameters'),
                    default: VaultConnection.table_exists? && VaultConnection.unscoped.count == 1 ? VaultConnection.unscoped.first.name : nil,
                    collection: VaultConnection.table_exists? ? proc { Hash[VaultConnection.unscoped.all.map { |vc| [vc.name, vc.name] }] } : [],
                    include_blank: _('Select Vault Connection'))
            setting('vault_policy_template',
                    full_name: N_('Vault Policy template name'),
                    type: :string,
                    description: N_('The name of the ProvisioningTemplate that will be used for Vault Policy'),
                    default: ProvisioningTemplate.unscoped.of_kind(:VaultPolicy).find_by(name: 'Default Vault Policy')&.name,
                    collection: proc { Hash[ProvisioningTemplate.unscoped.of_kind(:VaultPolicy).map { |tmpl| [tmpl.name, tmpl.name] }] },
                    include_blank: _('Select Template'))
            setting('vault_orchestration_enabled',
                    full_name: N_('Vault Orchestration enabled'),
                    type: :boolean,
                    description: N_('Enable or disable the Vault orchestration step for managing policies and auth methods'),
                    default: false)
          end
        end

        # add menu entry
        menu :top_menu, :vault_connections, url_hash: { controller: :vault_connections, action: :index },
                                            caption: N_('Vault Connections'),
                                            parent: :infrastructure_menu
      end
    end

    config.to_prepare do
      ::Host::Managed.include(ForemanVault::HostExtensions)
      ::ProvisioningTemplate.include(ForemanVault::ProvisioningTemplateExtensions)
      ::Foreman::Renderer::Scope::Base.include(ForemanVault::Macros)
      ::Foreman::Renderer.configure { |c| c.allowed_generic_helpers += [:vault_secret, :vault_issue_certificate] }
    rescue StandardError => e
      Rails.logger.warn "ForemanVault: skipping engine hook (#{e})"
    end

    initializer 'foreman_vault.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../..', __dir__), 'locale')
      locale_domain = 'foreman_vault'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_vault.trigger_jobs', after: :load_config_initializers do |_app|
      ::Foreman::Application.dynflow.config.on_init do |world|
        RefreshVaultTokens.spawn_if_missing(world)
      end
    end
  end
end
