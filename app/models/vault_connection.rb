# frozen_string_literal: true

class VaultConnection < ApplicationRecord
  include Authorizable

  validates_lengths_from_database
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true
  validates :url, format: URI.regexp(['http', 'https'])

  validates :token, presence: true, if: -> { role_id.nil? || secret_id.nil? }
  validates :token, inclusion: { in: [nil], message: _('AppRole or token must be blank') }, unless: -> { role_id.nil? || secret_id.nil? }
  validates :role_id, presence: true, if: -> { token.nil? }
  validates :role_id, inclusion: { in: [nil], message: _('AppRole or token must be blank') }, unless: -> { token.nil? }
  validates :secret_id, presence: true, if: -> { token.nil? }
  validates :secret_id, inclusion: { in: [nil], message: _('AppRole or token must be blank') }, unless: -> { token.nil? }

  before_validation :normalize_blank_values
  before_create :set_expire_time, unless: -> { token.nil? }
  before_update :update_expire_time, unless: -> { token.nil? }

  scope :with_approle, -> { where.not(role_id: nil).where.not(secret_id: nil) }
  scope :with_token, -> { where.not(token: nil) }
  scope :with_valid_token, -> { with_token.where(vault_error: nil).where('expire_time > ?', Time.zone.now) }

  delegate :fetch_expire_time, :fetch_secret, :issue_certificate,
           :policy, :policies, :put_policy, :delete_policy,
           :set_certificate, :certificates, :delete_certificate, to: :client

  def with_token?
    token.present?
  end

  def with_approle?
    role_id.present? && secret_id.present?
  end

  def token_valid?
    return false unless with_token?
    return false unless vault_error.nil?
    return true unless expire_time

    expire_time > Time.zone.now
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
    Foreman::Logging.exception('Failed to set vault expiry time', e)
    throw(:abort)
  end

  def update_expire_time
    self.expire_time = fetch_expire_time
    self.vault_error = nil
  rescue StandardError => e
    self.expire_time = nil
    self.vault_error = e.message
  end

  def normalize_blank_values
    attributes.each do |column, _value|
      self[column].present? || self[column] = nil
    end
  end

  def client
    @client ||= ForemanVault::VaultClient.new(url, token, role_id, secret_id)
  end
end
