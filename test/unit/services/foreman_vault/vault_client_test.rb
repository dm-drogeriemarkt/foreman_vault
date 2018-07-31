# frozen_string_literal: true

require 'test_helper'

class VaultClientTest < ActiveSupport::TestCase
  setup do
    @url = 'http://127.0.0.1:8200'
    @token = 'e57e5ef2-b25c-a0e5-65a6-863ab095dff6'
    @subject = ForemanVault::VaultClient.new(@url, @token)
  end

  describe '#token_expires_at' do
    test 'should return expire time' do
      time = '2018-08-01T20:08:55.525830559+02:00'
      response_body = "{\"data\":{\"expire_time\":\"#{time}\"}}"
      stub_request(:post, "#{@url}/v1/auth/token/lookup").to_return(status: 200, body: response_body)
      assert_equal Time.zone.parse(time), @subject.token_expires_at
    end
  end
end
