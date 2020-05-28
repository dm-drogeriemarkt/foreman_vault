# frozen_string_literal: true

require 'test_plugin_helper'

class VaultPolicyTest < ActiveSupport::TestCase
  subject { ForemanVault::VaultPolicy.new(host) }

  let(:host) { FactoryBot.create(:host, :managed) }

  setup do
    FactoryBot.create(:setting, name: 'vault_policy_template', value: 'Default Vault Policy')
  end

  describe 'valid?' do
    context 'with name and rules' do
      setup do
        subject.stubs(:name).returns('name')
        subject.stubs(:rules).returns('rules')
      end

      it { assert subject.valid? }
    end

    context 'without name' do
      setup do
        subject.stubs(:name).returns(nil)
        subject.stubs(:rules).returns('rules')
      end

      it { assert_not subject.valid? }
    end

    context 'without rules' do
      setup do
        subject.stubs(:name).returns('name')
        subject.stubs(:rules).returns(nil)
      end

      it { assert_not subject.valid? }
    end
  end

  describe '#name' do
    context 'without corresponding Vault Policy template' do
      it { assert_nil subject.name }
    end

    context 'with corresponding Vault Policy template' do
      setup do
        FactoryBot.create(:provisioning_template, :vault_policy, template: template)
      end

      let(:template) { '# NAME: <%= @host.name %>' }

      it { assert_equal host.name.parameterize, subject.name }

      context 'when name is empty' do
        let(:template) { '# NAME:' }

        it { assert_nil subject.name }
      end

      context 'when there is no name magic comment' do
        let(:template) { '# BLAH:' }

        it { assert_nil subject.name }
      end
    end
  end

  describe '#new?' do
    setup do
      FactoryBot.create(:provisioning_template, :vault_policy)
    end

    context 'policy already exists in the Vault' do
      setup do
        subject.stubs(:policies).returns([subject.name])
      end

      it { assert_not subject.new? }
    end

    context 'policy does not exist in the Vault' do
      setup do
        subject.stubs(:policies).returns([])
      end

      it { assert subject.new? }
    end
  end

  describe '#save' do
    context 'when valid' do
      it 'creates Vault Policy' do
        subject.stubs(:name).returns('name')
        subject.stubs(:rules).returns('rules')

        subject.expects(:put_policy).once.with(subject.name, subject.send(:rules))
        subject.save
      end
    end

    context 'when not valid' do
      it 'does not create Vault Policy' do
        subject.stubs(:valid?).returns(false)

        subject.expects(:set_certificate).never
        subject.save
      end
    end
  end

  describe '#delete' do
    context 'with name' do
      it 'deletes Vault Policy' do
        subject.stubs(:name).returns('name')

        subject.expects(:delete_policy).once.with(subject.name)
        subject.delete
      end
    end

    context 'without name' do
      it 'does not delete Vault Policy' do
        subject.stubs(:name).returns(nil)

        subject.expects(:delete_policy).never
        subject.delete
      end
    end
  end

  describe '#rules' do
    context 'without corresponding Vault Policy template' do
      it { assert_nil subject.send(:rules) }
    end

    context 'with corresponding Vault Policy template' do
      let(:rules) { 'path "secrets/data/*" { capabilities = ["create", "read", "update"] }' }

      setup do
        FactoryBot.create(:provisioning_template, :vault_policy, template: template)
      end

      let(:template) do
        <<~TEMPLATE
          # NAME: <%= @host.name %>

          #{rules}
        TEMPLATE
      end

      it { assert_equal "#{rules}\n", subject.send(:rules) }

      context 'when Vault Policy template renders empty' do
        let(:template) do
          <<~TEMPLATE
            # NAME: <%= @host.name %>

            <% if false %>
              #{rules}
            <% end %>
          TEMPLATE
        end

        it { assert_nil subject.send(:rules) }
      end
    end
  end
end
