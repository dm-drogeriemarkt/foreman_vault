# frozen_string_literal: true

class AddApproleToVaultConnection < ActiveRecord::Migration[5.1]
  def change
    add_column :vault_connections, :role_id, :string
    add_column :vault_connections, :secret_id, :string
  end
end
