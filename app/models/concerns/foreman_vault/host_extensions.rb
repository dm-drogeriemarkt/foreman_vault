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
      ::VaultConnection.find_by(name: params['vault_connection'])
    end
  end
end
