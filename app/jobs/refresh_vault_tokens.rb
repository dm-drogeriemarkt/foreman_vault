# frozen_string_literal: true

class RefreshVaultTokens < ApplicationJob
  def self.wait_until
    Time.zone.tomorrow.midnight + (SETTINGS&.[](:foreman_vault)&.[](:refresh_token_hour) || 0).hours
  end

  queue_as :vault_tokens_queue

  after_perform do
    self.class.set(wait_until: self.class.wait_until).perform_later
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
