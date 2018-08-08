# frozen_string_literal: true

class RefreshVaultToken < ApplicationJob
  def self.retry_wait
    (SETTINGS&.[](:foreman_vault)&.[](:refresh_token_retry_wait) || 5).minutes
  end

  def self.retry_attempts
    SETTINGS&.[](:foreman_vault)&.[](:refresh_token_retry_attempts) || 3
  end

  queue_as :vault_tokens_queue

  retry_on StandardError, wait: retry_wait, attempts: retry_attempts

  def perform(vault_connection_id)
    vault_connection = VaultConnection.with_valid_token.find(vault_connection_id)
    vault_connection.try(:renew_token!)
  end

  rescue_from(StandardError) do |error|
    Foreman::Logging.logger('background').error("Refresh Vault token: Error #{error}: #{error.backtrace}")
  end

  def humanized_name
    _('Refresh Vault token')
  end
end
