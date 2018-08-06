# frozen_string_literal: true

require 'test_plugin_helper'

class VaultSecretsTest < ActiveSupport::TestCase
  setup do
    host = FactoryBot.build_stubbed(:host)
    template = OpenStruct.new(name: 'Test', template: 'Test')
    source = Foreman::Renderer::Source::Database.new(template)

    @subject = Class.new(Foreman::Renderer::Scope::Base) do
      include ForemanVault::Renderer::Scope::Macros::VaultSecrets
    end.send(:new, host: host, source: source)
  end

  describe '#vault_secret' do
    before do
      @vault_connection = FactoryBot.create(:vault_connection)
      @secret_path = '/kv/my-secret'
      @response = OpenStruct.new(data: { foo: 'bar' })
      logical = mock
      logical.expects(:read).once.with(@secret_path).returns(@response)
      client = mock
      client.expects(:logical).once.returns(logical)
      Vault::Client.expects(:new).returns(client)
    end

    test 'should have vault_secret helper' do
      assert @subject.respond_to?(:vault_secret)
      assert_equal @response.data, @subject.vault_secret(@vault_connection.name, @secret_path)
    end
  end
end
