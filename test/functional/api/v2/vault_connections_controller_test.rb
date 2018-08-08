# frozen_string_literal: true

require 'test_plugin_helper'

module Api
  module V2
    class VaultConnectionsControllerTest < ActionController::TestCase
      describe '#create' do
        test 'should create valid' do
          response = OpenStruct.new(data: { expire_time: '2018-08-01T20:08:55.525830559+02:00' })
          auth_token = mock.tap { |object| object.expects(:lookup_self).returns(response) }
          client = mock.tap { |object| object.expects(:auth_token).returns(auth_token) }
          Vault::Client.expects(:new).returns(client)

          VaultConnection.any_instance.stubs(:valid?).returns(true)
          params = { name: 'valid', url: 'http://localhost:8200', token: 'token' }
          post :create, params: { vault_connection: params }
          assert_response :success
        end

        test 'should not create invalid' do
          post :create
          assert_response :unprocessable_entity
        end
      end
    end
  end
end
