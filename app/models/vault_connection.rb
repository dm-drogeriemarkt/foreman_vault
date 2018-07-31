# frozen_string_literal: true

class VaultConnection < ApplicationRecord
  include Authorizable

  validates :name, presence: true, uniqueness: true
  validates :url, :token, presence: true

  before_create :set_expires_at
  before_update :update_expires_at

  def token_valid?
    vault_status.nil? && expires_at && expires_at > Time.zone.now
  end

  private

  def set_expires_at
    self.expires_at = client.token_expires_at
  rescue ForemanVault::VaultClient::VaultClientError => e
    errors.add(:base, e.message)
    throw(:abort)
  end

  def update_expires_at
    self.expires_at = client.token_expires_at
    self.vault_status = nil
  rescue ForemanVault::VaultClient::VaultClientError => e
    self.expires_at = nil
    self.vault_status = e.message
  end

  def client
    @client ||= ForemanVault::VaultClient.new(url, token)
  end
end
