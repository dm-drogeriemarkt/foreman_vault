# frozen_string_literal: true

require 'vault'

module ForemanVault
  class VaultClient
    def initialize(base_url, token)
      @base_url = base_url
      @token = token
    end

    def expire_time
      response = client.auth_token.lookup(token)
      Time.zone.parse(response.data[:expire_time])
    end

    private

    attr_reader :base_url, :token

    def client
      @client ||= Vault::Client.new(address: base_url, token: token)
    end
  end
end
