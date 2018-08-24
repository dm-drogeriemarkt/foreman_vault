# frozen_string_literal: true

require 'test_plugin_helper'

class RefreshVaultTokenTest < ActiveJob::TestCase
  setup do
    response = OpenStruct.new(data: { expire_time: '2018-08-09' })
    auth_token = mock.tap { |object| object.expects(:lookup_self).returns(response) }
    client = mock.tap { |object| object.expects(:auth_token).returns(auth_token) }
    Vault::Client.expects(:new).returns(client)
    @vault_connection = FactoryBot.create(:vault_connection)
  end

  test 'should refresh vault token' do
    travel_to Time.zone.parse('2018-08-08')
    new_expire_time = '2018-08-10'
    auth_token = mock.tap do |object|
      renew_self_response = OpenStruct.new(data: nil)
      object.expects(:renew_self).once.returns(renew_self_response)
      lookup_self_response = OpenStruct.new(data: { expire_time: new_expire_time })
      object.expects(:lookup_self).once.returns(lookup_self_response)
    end
    client = mock.tap { |object| object.expects(:auth_token).twice.returns(auth_token) }
    Vault::Client.expects(:new).once.returns(client)

    perform_enqueued_jobs { RefreshVaultToken.perform_later(@vault_connection.id) }
    assert_equal Time.zone.parse(new_expire_time), @vault_connection.reload.expire_time
  end
end
