# frozen_string_literal: true

require 'test_plugin_helper'

module Api
  module V2
    class VaultConnectionsControllerTest < ActionController::TestCase
      setup do
        @vault_connection = FactoryBot.create(:vault_connection, :without_callbacks)
      end

      describe '#index' do
        test 'should get vault connections' do
          get :index
          response = ActiveSupport::JSON.decode(@response.body)
          assert_response :success
          assert response['results'].any?, 'Should respond with VaultConnections'
        end
      end

      describe '#show' do
        test 'should get vault connection detail' do
          get :show, params: { id: @vault_connection.to_param }
          assert_response :success
          vault_connection = ActiveSupport::JSON.decode(@response.body)
          assert_not vault_connection.empty?
          assert_equal vault_connection['name'], @vault_connection.name
        end
      end

      describe '#create' do
        test 'should create valid' do
          response = OpenStruct.new(data: { expire_time: '2018-08-01' })
          auth_token = mock.tap { |object| object.expects(:lookup_self).returns(response) }
          client = mock.tap { |object| object.expects(:auth_token).returns(auth_token) }
          Vault::Client.expects(:new).returns(client)

          params = { name: 'valid', url: 'http://localhost:8200', token: 'token' }
          post :create, params: { vault_connection: params }
          assert_response :success
        end

        test 'should not create invalid' do
          post :create
          assert_response :unprocessable_entity
        end
      end

      describe '#update' do
        test 'should update valid' do
          response = OpenStruct.new(data: { expire_time: '2018-08-01' })
          auth_token = mock.tap { |object| object.expects(:lookup_self).returns(response) }
          client = mock.tap { |object| object.expects(:auth_token).returns(auth_token) }
          Vault::Client.expects(:new).returns(client)

          params = { name: 'New name', url: 'http://localhost:8200', token: 'token' }
          put :update, params: { id: @vault_connection.to_param, vault_connection: params }
          response = ActiveSupport::JSON.decode(@response.body)
          assert_response :success
          assert_equal params[:name], response['name']
        end

        test 'should not update invalid' do
          params = { name: nil, url: nil, token: nil }
          put :update, params: { id: @vault_connection.to_param, vault_connection: params }
          assert_response :unprocessable_entity
        end
      end

      describe '#destroy' do
        test 'should destroy' do
          assert VaultConnection.exists?(@vault_connection.id)
          delete :destroy, params: { id: @vault_connection.to_param }
          assert_response :success
          refute VaultConnection.exists?(@vault_connection.id)
        end
      end
    end
  end
end
