# frozen_string_literal: true

module Api
  module V2
    class VaultConnectionsController < V2::BaseController
      include Api::Version2
      include ForemanVault::Controller::Parameters::VaultConnection

      def_param_group :vault_connection do
        param :vault_connection, Hash, action_aware: true, required: true do
          param :name, String, required: true
          param :url, String, required: true
          param :token, String, required: true
        end
      end

      api :POST, '/vault_connections/', N_('Create a Vault Connection')
      param_group :vault_connection, as: :create

      def create
        @vault_connection = VaultConnection.new(vault_connection_params)
        process_response @vault_connection.save
      end
    end
  end
end
