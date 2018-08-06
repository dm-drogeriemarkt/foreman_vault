# frozen_string_literal: true

class CreateVaultConnection < ActiveRecord::Migration[5.1]
  def change
    create_table :vault_connections do |t|
      t.string :name
      t.string :url
      t.string :token
      t.string :vault_status
      t.datetime :expire_time

      t.timestamps
    end
  end
end
