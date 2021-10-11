# frozen_string_literal: true

require 'test_plugin_helper'
require 'rake'

module ForemanVault
  class PushAuthMethodsTest < ActiveSupport::TestCase
    TASK_NAME = 'foreman_vault:auth_methods:push'

    let(:host) { FactoryBot.create(:host, :managed) }
    let(:vault_connection) { FactoryBot.create(:vault_connection, :without_callbacks) }

    setup do
      Rake.application.rake_require 'tasks/foreman_vault_tasks'

      Rake::Task.define_task(:environment)
      Rake::Task[TASK_NAME].reenable

      FactoryBot.create(:parameter, name: 'vault_connection', value: vault_connection.name)

      ForemanVault::VaultAuthMethod.any_instance.stubs(:vault_policy_name).returns('vault_policy_name')
      ForemanVault::VaultAuthMethod.any_instance.stubs(:certificate).returns('cert')

      ForemanVault::VaultClient.any_instance.stubs(:set_certificate).returns(true)
    end

    it 'does successfully push auth methods' do
      host

      stdout, _stderr = capture_io do
        Rake::Task[TASK_NAME].invoke
      end

      assert_match("[1/1] Auth-Method of \"#{host.name}\" pushed to Vault server \"#{host.vault_connection.url}\"", stdout)
    end

    it 'does throw an error when host was deleted' do
      host

      Host::Managed.any_instance.stubs(:reload).raises(ActiveRecord::RecordNotFound)

      stdout, _stderr = capture_io do
        Rake::Task[TASK_NAME].invoke
      end

      assert_match("[1/1] Failed to push \"#{host.name}\"", stdout)
    end
  end
end
