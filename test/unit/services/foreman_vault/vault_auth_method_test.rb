# frozen_string_literal: true

require 'test_plugin_helper'

class VaultAuthMethodTest < ActiveSupport::TestCase
  subject { ForemanVault::VaultAuthMethod.new(host) }

  let(:host) { FactoryBot.create(:host, :managed) }

  describe '#name' do
    context 'with host and vault_policy_name' do
      setup do
        subject.stubs(:vault_policy_name).returns('vault_policy_name')
      end

      it { assert_equal "#{host}-vault_policy_name".parameterize, subject.name }
    end

    context 'without host' do
      setup do
        subject.stubs(:host).returns(nil)
        subject.stubs(:vault_policy_name).returns('vault_policy_name')
      end

      it { assert_nil subject.name }
    end

    context 'without vault_policy_name' do
      setup do
        subject.stubs(:vault_policy_name).returns(nil)
      end

      it { assert_nil subject.name }
    end
  end

  describe 'valid?' do
    context 'with name and certificate' do
      setup do
        subject.stubs(:name).returns('name')
        subject.stubs(:certificate).returns('cert')
      end

      it { assert subject.valid? }
    end

    context 'without name' do
      setup do
        subject.stubs(:name).returns(nil)
        subject.stubs(:certificate).returns('cert')
      end

      it { assert_not subject.valid? }
    end

    context 'without certificate' do
      setup do
        subject.stubs(:name).returns('name')
        subject.stubs(:certificate).returns(nil)
      end

      it { assert_not subject.valid? }
    end
  end

  describe '#save' do
    context 'when valid' do
      it 'creates auth method in the Vault' do
        subject.stubs(:name).returns('name')
        subject.stubs(:vault_policy_name).returns('vault_policy_name')
        subject.stubs(:certificate).returns('cert')

        subject.expects(:set_certificate).once.with(
          'name',
          certificate: 'cert',
          token_policies: 'vault_policy_name',
          allowed_common_names: [host.fqdn]
        )
        subject.save
      end
    end

    context 'when not valid' do
      it 'does not create auth method in the Vault' do
        subject.stubs(:valid?).returns(false)

        subject.expects(:set_certificate).never
        subject.save
      end
    end
  end

  describe '#delete' do
    context 'when valid' do
      it 'deletes Certificate' do
        subject.stubs(:valid?).returns(true)

        subject.expects(:delete_certificate).once.with(subject.name)
        subject.delete
      end
    end

    context 'when not valid' do
      it 'does not delete Certificate' do
        subject.stubs(:valid?).returns(false)

        subject.expects(:delete_certificate).never
        subject.delete
      end
    end
  end

  describe '#certificate' do
    setup do
      Setting.find_by(name: 'ssl_ca_file').update(value: cert_path)
    end

    context 'when certificate file can be read' do
      let(:cert_path) { File.join(ForemanVault::Engine.root, 'test/fixtures/ca.crt') }

      it { assert_equal File.read(cert_path), subject.send(:certificate) }
    end

    context 'when certificate file cannot be read' do
      let(:cert_path) { '/tmp/invalid.crt' }

      it { assert_not subject.send(:certificate) }
    end
  end
end
