# frozen_string_literal: true

class VaultConnectionsController < ::ApplicationController
  include ForemanVault::Controller::Parameters::VaultConnection

  before_action :find_resource, only: [:edit, :update, :destroy]

  def index
    @vault_connections = resource_base.all
  end

  def new
    @vault_connection = VaultConnection.new
  end

  def create
    @vault_connection = VaultConnection.new(vault_connection_params)
    if @vault_connection.save
      process_success
    else
      process_error
    end
  end

  def edit; end

  def update
    if @vault_connection.update(vault_connection_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @vault_connection.destroy
      process_success
    else
      process_error
    end
  end
end
