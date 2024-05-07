# frozen_string_literal: true

module ForemanVault
  module Orchestration
    module VaultPolicy
      extend ActiveSupport::Concern

      MAGIC_COMMENT_PREFIX = '# NAME: '

      included do
        after_validation :queue_vault_push
        before_destroy :queue_vault_destroy
      end

      protected

      def queue_vault_push
        return if !managed? || errors.any?
        return unless orchestration_enabled?
        return unless vault_policy.valid?
        return unless vault_auth_method.valid?

        queue.create(name: _('Push %s data to Vault') % self, priority: 100,
          action: [self, :set_vault])
      end

      def queue_vault_destroy
        return if !managed? || errors.any?
        return unless orchestration_enabled?
        return unless vault_auth_method.valid?

        queue.create(name: _('Clear %s Vault data') % self, priority: 60,
          action: [self, :del_vault])
      end

      def set_vault
        logger.info "Pushing #{name} data to Vault"

        vault_policy.save if vault_policy.new?
        vault_auth_method.save
        true
      rescue StandardError => e
        Foreman::Logging.exception("Failed to push #{name} data to Vault.", e)
        failure format(_('Failed to push %{name} data to Vault: %{message}\n '), name: name, message: e.message), e
      end

      def del_vault
        logger.info "Clearing #{name} Vault data"

        vault_auth_method&.delete
      rescue StandardError => e
        Foreman::Logging.exception("Failed to clear #{name} Vault data", e)
        failure format(_("Failed to clear %{name} Vault data: %{message}\n "), name: name, message: e.message), e
      end

      def orchestration_enabled?
        return false unless Setting[:vault_orchestration_enabled]
        return false if vault_connection.nil?

        true
      end
    end
  end
end
