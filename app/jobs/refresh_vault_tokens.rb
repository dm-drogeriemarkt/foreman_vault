# frozen_string_literal: true

class RefreshVaultTokens < ApplicationJob
  def self.wait_time
    (SETTINGS&.[](:foreman_vault)&.[](:refresh_tokens_wait_time) || 30).minutes
  end

  queue_as :vault_tokens_queue

  after_perform do
    self.class.set(wait: self.class.wait_time).perform_later
  end

  def perform
    VaultConnection.with_valid_token.each(&:perform_renew_token)
  end

  rescue_from(StandardError) do |error|
    Foreman::Logging.logger('background').error("Refresh Vault tokens: Error #{error}: #{error.backtrace}")
  end

  def humanized_name
    _('Refresh Vault tokens')
  end
end
