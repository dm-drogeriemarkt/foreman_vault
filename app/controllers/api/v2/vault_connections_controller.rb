# frozen_string_literal: true

module Api
  module V2
    class VaultConnectionsController < V2::BaseController
      include Api::Version2
      include ForemanVault::Controller::Parameters::VaultConnection

      before_action :find_resource, only: [:show, :update, :destroy]

      api :GET, '/vault_connections/', N_('List VaultConnections')
      def index
        @vault_connections = resource_scope
      end

      api :GET, '/vault_connections/:id', N_('Show VaultConnection details')
      param :id, :identifier, required: true
      def show; end

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

      api :PUT, '/vault_connections/:id', N_('Update a VaultConnection')
      param :id, :identifier, required: true
      param_group :vault_connection
      def update
        process_response @vault_connection.update(vault_connection_params)
      end

      api :DELETE, '/vault_connections/:id', N_('Delete a VaultConnection')
      param :id, :identifier, required: true
      def destroy
        process_response @vault_connection.destroy
      end
    end
  end
end
