# frozen_string_literal: true

module ForemanVault
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      include ForemanVault::Orchestration::VaultPolicy
    end

    def vault_policy
      VaultPolicy.new(self)
    end

    def vault_auth_method
      VaultAuthMethod.new(self)
    end

    def vault_connection
      return unless vault_connection_name

      ::VaultConnection.find_by(name: vault_connection_name)
    end

    private

    def vault_connection_name
      @vault_connection_name ||= params['vault_connection'] || Setting['vault_connection']
    end
  end
end
