# frozen_string_literal: true

class VaultConnection < ApplicationRecord
  include Authorizable

  validates_lengths_from_database
  validates :name, presence: true, uniqueness: true
  validates :url, :token, presence: true
  validates :url, format: URI.regexp(['http', 'https'])

  before_create :set_expire_time
  before_update :update_expire_time

  scope :with_valid_token, -> { where(vault_error: nil).where('expire_time > ?', Time.zone.now) }

  delegate :fetch_expire_time, :fetch_secret, :issue_certificate, to: :client

  def token_valid?
    vault_error.nil? && expire_time && expire_time > Time.zone.now
  end

  def renew_token!
    client.renew_token
    save!
  rescue StandardError => e
    # rubocop:disable Rails/SkipsModelValidations
    update_column(:vault_error, e.message)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def perform_renew_token
    RefreshVaultToken.perform_later(id)
  end

  private

  def set_expire_time
    self.expire_time = fetch_expire_time
  rescue StandardError => e
    errors.add(:base, e.message)
    throw(:abort)
  end

  def update_expire_time
    self.expire_time = fetch_expire_time
    self.vault_error = nil
  rescue StandardError => e
    self.expire_time = nil
    self.vault_error = e.message
  end

  def client
    @client ||= ForemanVault::VaultClient.new(url, token)
  end
end
