# frozen_string_literal: true

require 'vault'

module ForemanVault
  class VaultClient
    def initialize(base_url, token)
      @base_url = base_url
      @token = token
    end

    def fetch_expire_time
      response = client.auth_token.lookup_self
      Time.zone.parse(response.data[:expire_time])
    end

    def fetch_secret(secret_path)
      response = client.logical.read(secret_path)
      raise NoDataError.new(N_('There is no available data for path: %s'), secret_path) unless response

      response.data
    end

    def issue_certificate(secret_path, *options)
      response = client.logical.write(secret_path, *options)
      raise NoDataError.new(N_('Could not issue certificate: %s'), secret_path) unless response
      response.data
    end

    def renew_token
      client.auth_token.renew_self
    end

    private

    class VaultClientError < Foreman::Exception; end
    class NoDataError < VaultClientError; end

    attr_reader :base_url, :token

    def client
      @client ||= Vault::Client.new(address: base_url, token: token)
    end
  end
end
