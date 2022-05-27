# frozen_string_literal: true

class Setting
  class Vault < ::Setting
    BLANK_ATTRS << 'vault_connection'
    BLANK_ATTRS << 'vault_policy_template'

    def self.default_settings
      [set_vault_connection, set_vault_policy_template, set_vault_orchestration_enabled]
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.load_defaults
      # Check the table exists
      return unless super

      transaction do
        default_settings.each do |s|
          setting = create! s.update(category: 'Setting::Vault')

          Foreman.try(:settings)&._add(
            s[:name],
            s.slice(:description, :default, :full_name, :encrypted)
             .merge(category: 'Setting::Vault')
             .yield_self do |params|
               unless Gem::Version.new(SETTINGS[:version].notag) < Gem::Version.new('2.6')
                 params[:context] = :vault
                 params[:type] = setting.settings_type
               end
               params
             end
          )
        end
      end

      true
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def self.humanized_category
      N_('Vault')
    end

    class << self
      private

      def set_vault_connection
        set(
          'vault_connection',
          N_('Default Vault Connection that can be override using parameters'),
          default_vault_connection,
          N_('Default Vault Connection'),
          nil,
          collection: vault_connections_collection,
          include_blank: _('Select Vault Connection')
        )
      end

      def default_vault_connection
        return nil unless VaultConnection.table_exists?
        return unless VaultConnection.unscoped.count == 1

        VaultConnection.unscoped.first.name
      end

      def vault_connections_collection
        return [] unless VaultConnection.table_exists?

        proc { Hash[VaultConnection.unscoped.all.map { |vc| [vc.name, vc.name] }] }
      end

      def set_vault_policy_template
        set(
          'vault_policy_template',
          N_('The name of the ProvisioningTemplate that will be used for Vault Policy'),
          default_vault_policy_template,
          N_('Vault Policy template name'),
          nil,
          collection: vault_policy_templates_collection,
          include_blank: _('Select Template')
        )
      end

      def default_vault_policy_template
        ProvisioningTemplate.unscoped.of_kind(:VaultPolicy).find_by(name: 'Default Vault Policy')&.name
      end

      def vault_policy_templates_collection
        proc { Hash[ProvisioningTemplate.unscoped.of_kind(:VaultPolicy).map { |tmpl| [tmpl.name, tmpl.name] }] }
      end

      def set_vault_orchestration_enabled
        set(
          'vault_orchestration_enabled',
          N_('Enable or disable the Vault orchestration step for managing policies and auth methods'),
          false,
          N_('Vault Orchestration enabled')
        )
      end
    end
  end
end
