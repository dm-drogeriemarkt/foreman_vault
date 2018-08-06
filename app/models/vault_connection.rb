# frozen_string_literal: true

require 'vault'

class VaultConnection < ApplicationRecord
  include Authorizable

  validates :name, presence: true, uniqueness: true
  validates :url, :token, presence: true

  before_create :set_expire_time
  before_update :update_expire_time

  delegate :fetch_expire_time, :fetch_secret, to: :client

  def token_valid?
    vault_status.nil? && expire_time && expire_time > Time.zone.now
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
    self.vault_status = nil
  rescue StandardError => e
    self.expire_time = nil
    self.vault_status = e.message
  end

  def client
    @client ||= ForemanVault::VaultClient.new(url, token)
  end
end
