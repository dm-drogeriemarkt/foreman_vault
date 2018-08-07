# frozen_string_literal: true

require 'test_plugin_helper'

class MacrosTest < ActiveSupport::TestCase
  describe '#vault_secret' do
    test 'should have vault_secret helper' do
      host = FactoryBot.build_stubbed(:host)
      template = OpenStruct.new(name: 'Test', template: 'Test')
      source = Foreman::Renderer::Source::Database.new(template)
      subject = Class.new(Foreman::Renderer::Scope::Base) do
        include ForemanVault::Macros
      end.send(:new, host: host, source: source)
      vault_connection = FactoryBot.create(:vault_connection)
      secret_path = '/kv/my-secret'
      response = OpenStruct.new(data: { foo: 'bar' })
      logical = mock
      logical.expects(:read).once.with(secret_path).returns(response)
      client = mock
      client.expects(:logical).once.returns(logical)
      Vault::Client.expects(:new).returns(client)

      assert subject.respond_to?(:vault_secret)
      assert_equal response.data, subject.vault_secret(vault_connection.name, secret_path)
    end
  end
end
