# frozen_string_literal: true

require 'test_helper'

class VaultClientTest < ActiveSupport::TestCase
  setup do
    @url = 'http://127.0.0.1:8200'
    @token = 'e57e5ef2-b25c-a0e5-65a6-863ab095dff6'
    @subject = ForemanVault::VaultClient.new(@url, @token)
  end

  describe '#expire_time' do
    setup do
      @time = '2018-08-01T20:08:55.525830559+02:00'
      response = OpenStruct.new(data: { expire_time: @time })
      auth_token = mock('auth_token', lookup: response)
      client = mock('client', auth_token: auth_token)
      Vault::Client.expects(:new).returns(client)
    end

    test 'should return expire time' do
      assert_equal Time.zone.parse(@time), @subject.expire_time
    end
  end
end
