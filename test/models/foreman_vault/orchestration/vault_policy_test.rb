# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanVault
  module Orchestration
    class VaultPolicyTest < ActiveSupport::TestCase
      describe '#queue_vault_push' do
        let(:host) { FactoryBot.create(:host, :managed) }
        let(:queue) { mock('queue') }
        let(:vault_policy) { mock('vault_policy') }
        let(:vault_auth_method) { mock('vault_auth_method') }
        let(:vault_connection) { FactoryBot.create(:vault_connection, :without_callbacks) }

        setup do
          host.stubs(:queue).returns(queue)
          host.stubs(:vault_policy).returns(vault_policy)
          host.stubs(:vault_auth_method).returns(vault_auth_method)
          FactoryBot.create(:parameter, name: 'vault_connection', value: vault_connection.name)
          if Setting.find_by(name: 'vault_orchestration_enabled')
            Setting['vault_orchestration_enabled'] = true
          else
            FactoryBot.create(:setting, name: :vault_orchestration_enabled, value: true)
          end
        end

        test 'should queue Vault orchestration' do
          vault_policy.stubs(:valid?).returns(true)
          vault_auth_method.stubs(:valid?).returns(true)

          queue.expects(:create).with(
            name: "Push #{host} data to Vault",
            priority: 100,
            action: [host, :set_vault]
          ).once
          host.send(:queue_vault_push)
        end

        context 'when vault_policy is not valid' do
          test 'should not queue Vault orchestration' do
            vault_auth_method.stubs(:valid?).returns(true)

            vault_policy.expects(:valid?).returns(false)
            queue.expects(:create).never
            host.send(:queue_vault_push)
          end
        end

        context 'when vault_auth_method is not valid' do
          test 'should not queue Vault orchestration' do
            vault_policy.stubs(:valid?).returns(true)

            vault_auth_method.expects(:valid?).returns(false)
            queue.expects(:create).never
            host.send(:queue_vault_push)
          end
        end
      end

      describe '#queue_vault_destroy' do
        let(:host) { FactoryBot.create(:host, :managed) }
        let(:queue) { mock('queue') }
        let(:vault_policy) { mock('vault_policy') }
        let(:vault_auth_method) { mock('vault_auth_method') }
        let(:vault_connection) { FactoryBot.create(:vault_connection, :without_callbacks) }

        setup do
          host.stubs(:queue).returns(queue)
          host.stubs(:vault_policy).returns(vault_policy)
          host.stubs(:vault_auth_method).returns(vault_auth_method)
          FactoryBot.create(:parameter, name: 'vault_connection', value: vault_connection.name)
          if Setting.find_by(name: 'vault_orchestration_enabled')
            Setting['vault_orchestration_enabled'] = true
          else
            FactoryBot.create(:setting, name: :vault_orchestration_enabled, value: true)
          end
        end

        context 'when auth_method is valid' do
          test 'should queue del_vault' do
            vault_auth_method.stubs(:valid?).returns(true)

            queue.expects(:create).with(
              name: "Clear #{host} Vault data",
              priority: 60,
              action: [host, :del_vault]
            ).once
            host.send(:queue_vault_destroy)
          end
        end

        context 'when auth_method is not valid' do
          test 'should not queue del_vault' do
            vault_auth_method.stubs(:valid?).returns(false)

            queue.expects(:create).never
            host.send(:queue_vault_destroy)
          end
        end
      end

      describe '#set_vault' do
        let(:host) { FactoryBot.create(:host, :managed) }
        let(:vault_connection) { FactoryBot.create(:vault_connection, :without_callbacks) }
        let(:new_owner) { FactoryBot.create(:usergroup, name: 'MyOwner') }

        let(:vault_policies) { [] }
        let(:get_policies_request) do
          stub_request(:get, "#{vault_connection.url}/v1/sys/policy").to_return(
            status: 200, headers: { 'Content-Type': 'application/json' },
            body: { policies: vault_policies }.to_json
          )
        end

        let(:new_policy_name) { "#{new_owner}-#{host.name}".parameterize }
        let(:put_policy_request) do
          url = "#{vault_connection.url}/v1/sys/policy/#{new_policy_name}"
          rules = "# allow access to secrets from puppet hosts from <foreman_owner>-<hostname>\npath \"secrets/data/MyOwner/#{host.name}/*\" {\n    capabilities = [\"create\", \"read\", \"update\"]\n}\n"
          stub_request(:put, url).with(body: JSON.fast_generate(rules: rules)).to_return(status: 200)
        end

        let(:new_auth_method_name) { host.name.parameterize }
        let(:post_auth_method_request) do
          url = "#{vault_connection.url}/v1/auth/cert/certs/#{new_auth_method_name}"
          stub_request(:post, url).with(
            body: JSON.fast_generate(
              certificate: host.vault_auth_method.send(:certificate),
              token_policies: new_policy_name,
              allowed_common_names: [host.fqdn]
            )
          ).to_return(status: 200)
        end

        let(:override_old_auth_method_request) do
          url = "#{vault_connection.url}/v1/auth/cert/certs/#{host.vault_auth_method.name}"
          stub_request(:delete, url).to_return(status: 200)
        end

        setup do
          Setting['ssl_ca_file'] = File.join(ForemanVault::Engine.root, 'test/fixtures/ca.crt')
          if Setting.find_by(name: 'vault_orchestration_enabled')
            Setting['vault_orchestration_enabled'] = true
          else
            FactoryBot.create(:setting, name: :vault_orchestration_enabled, value: true)
          end
          if Setting.find_by(name: 'vault_policy_template')
            Setting['vault_policy_template'] = 'Default Vault Policy'
          else
            FactoryBot.create(:setting, :vault_policy)
          end
          FactoryBot.create(:provisioning_template, :vault_policy, name: Setting['vault_policy_template'])
          FactoryBot.create(:parameter, name: 'vault_connection', value: vault_connection.name)
          host.stubs(:skip_orchestration_for_testing?).returns(false)

          get_policies_request
          put_policy_request
          post_auth_method_request

          host.update(owner: new_owner)
        end

        it { assert_requested(post_auth_method_request) }

        context 'when policy already exists on Vault' do
          let(:vault_policies) { [new_policy_name] }

          it { assert_not_requested(put_policy_request) }
        end

        context 'when policy does not exist on Vault' do
          let(:vault_policies) { [] }

          it { assert_requested(put_policy_request) }
        end
      end
    end
  end
end
