# frozen_string_literal: true

module ForemanVault
  module Macros
    def vault_secret(vault_connection_name, secret_path)
      vault = VaultConnection.find_by!(name: vault_connection_name)
      raise VaultError.new(N_('Invalid token for %s'), vault.name) unless vault.token_valid?

      vault.fetch_secret(secret_path)
    rescue ActiveRecord::RecordNotFound => e
      raise VaultError, e.message
    end

    def vault_issue_certificate(vault_connection_name, secret_path, *options)
      vault = VaultConnection.find_by!(name: vault_connection_name)
      raise VaultError.new(N_('Invalid token for %s'), vault.name) unless vault.token_valid?
      vault.issue_certificate(secret_path, *options)
    rescue ActiveRecord::RecordNotFound => e
      raise VaultError, e.message
    end

    class VaultError < Foreman::Exception; end
  end
end
