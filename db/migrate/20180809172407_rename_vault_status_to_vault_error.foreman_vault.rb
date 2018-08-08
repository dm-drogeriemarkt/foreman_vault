# frozen_string_literal: true

class RenameVaultStatusToVaultError < ActiveRecord::Migration[5.1]
  def change
    rename_column :vault_connections, :vault_status, :vault_error
  end
end
