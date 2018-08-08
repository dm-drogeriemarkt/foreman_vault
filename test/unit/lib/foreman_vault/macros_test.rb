# frozen_string_literal: true

require 'test_plugin_helper'

class MacrosTest < ActiveSupport::TestCase
  class TestScope < Foreman::Renderer::Scope::Base
    include ::ForemanVault::Macros
  end

  describe '#vault_secret' do
    test 'should have vault_secret helper' do
      host = FactoryBot.build_stubbed(:host)
      template = OpenStruct.new(name: 'Test', template: 'Test')
      source = Foreman::Renderer::Source::Database.new(template)

      vault_connection = FactoryBot.create(:vault_connection)
      secret_path = '/kv/my-secret'
      response = OpenStruct.new(data: { foo: 'bar' })
      logical = mock.tap { |object| object.expects(:read).once.with(secret_path).returns(response) }
      client = mock.tap { |object| object.expects(:logical).once.returns(logical) }
      Vault::Client.expects(:new).returns(client)

      subject = TestScope.new(host: host, source: source)

      assert subject.respond_to?(:vault_secret)
      assert_equal response.data, subject.vault_secret(vault_connection.name, secret_path)
    end
  end
end
