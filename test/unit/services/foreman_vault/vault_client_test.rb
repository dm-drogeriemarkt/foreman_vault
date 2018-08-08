# frozen_string_literal: true

require 'test_helper'

class VaultClientTest < ActiveSupport::TestCase
  setup do
    @subject = ForemanVault::VaultClient.new('http://127.0.0.1:8200', 'e57e5ef2-b25c-a0e5-65a6-863ab095dff6')
    @client = mock
    Vault::Client.expects(:new).returns(@client)
  end

  describe '#fetch_expire_time' do
    setup do
      @time = '2018-08-01T20:08:55.525830559+02:00'
      response = OpenStruct.new(data: { expire_time: @time })
      auth_token = mock.tap { |object| object.expects(:lookup_self).once.returns(response) }
      @client.expects(:auth_token).once.returns(auth_token)
    end

    test 'should return expire time' do
      assert_equal Time.zone.parse(@time), @subject.fetch_expire_time
    end
  end

  describe '#fetch_secret' do
    setup do
      @secret_path = '/kv/my-secret'
      @data = { foo: 'bar' }
      response = OpenStruct.new(data: @data)
      logical = mock.tap { |object| object.expects(:read).once.with(@secret_path).returns(response) }

      @client.expects(:logical).once.returns(logical)
    end

    test 'should return expire time' do
      assert_equal @data, @subject.fetch_secret(@secret_path)
    end
  end
end
