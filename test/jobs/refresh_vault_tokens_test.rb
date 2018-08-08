# frozen_string_literal: true

require 'test_plugin_helper'

class RefreshVaultTokensTest < ActiveJob::TestCase
  test 'should refresh vault token for valid VaultConnection' do
    valid_vault_connection = FactoryBot.create(:vault_connection, :without_callbacks)
    invalid_vault_connection = FactoryBot.create(:vault_connection, :invalid, :without_callbacks)

    assert valid_vault_connection.token_valid?
    assert_not invalid_vault_connection.token_valid?
    RefreshVaultToken.expects(:perform_later).once.with(valid_vault_connection.id).returns(true)

    RefreshVaultTokens.expects(:set).once.returns(nil) # Hack to prevent an infinite loop

    perform_enqueued_jobs { RefreshVaultTokens.perform_later }
  end
end
