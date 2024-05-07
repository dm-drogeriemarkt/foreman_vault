# frozen_string_literal: true

require 'test_plugin_helper'

class VaultClientTest < ActiveSupport::TestCase
  subject do
    ForemanVault::VaultClient.new(base_url, token, nil, nil).tap do |vault_client|
      vault_client.instance_variable_set(:@client, client)
    end
  end

  let(:client) { Vault::Client }
  let(:base_url) { 'http://127.0.0.1:8200' }
  let(:token) { 's.opkr0MAqme5e5nr3i2or5wZC' }

  describe 'auth with AppRole' do
    subject { ForemanVault::VaultClient.new(base_url, nil, role_id, secret_id) }

    let(:role_id) { '8403910c-e563-d2f2-1c77-6e26319be8b5' }
    let(:secret_id) { '1058434b-b4aa-bf5a-b376-a15d9efb1059' }

    setup do
      stub_request(:post, "#{base_url}/v1/auth/approle/login").with(
        body: {
          role_id: role_id,
          secret_id: secret_id,
        }
      ).to_return(
        status: 200,
        headers: { 'Content-Type': 'application/json' },
        body: {
          auth: {
            client_token: token,
          },
        }.to_json
      )
    end

    it { assert_equal token, subject.send(:client).token }
  end

  describe 'auth with token' do
    subject { ForemanVault::VaultClient.new(base_url, token, nil, nil) }

    it { assert_equal token, subject.send(:client).token }
  end

  describe '#fetch_expire_time' do
    setup do
      @time = '2018-08-01T20:08:55.525830559+02:00'
      response = OpenStruct.new(data: { expire_time: @time })
      auth_token = mock.tap { |object| object.expects(:lookup_self).once.returns(response) }
      client.expects(:auth_token).once.returns(auth_token)
    end

    test 'should return expire time' do
      assert_equal Time.zone.parse(@time), subject.fetch_expire_time
    end
  end

  describe '#fetch_secret' do
    setup do
      @secret_path = '/kv/my-secret'
      @data = { foo: 'bar' }
      response = OpenStruct.new(data: @data)
      logical = mock.tap { |object| object.expects(:read).once.with(@secret_path).returns(response) }

      client.expects(:logical).once.returns(logical)
    end

    test 'should return expire time' do
      assert_equal @data, subject.fetch_secret(@secret_path)
    end
  end

  describe '#fetch_certificate' do
    setup do
      @pki_path = '/pkiEngine/issue/testRole'
      @data = {
        certificate: 'CERTIFICATE_DATA',
        expiration: 1_582_116_230,
        issuing_ca: 'CA_CERTIFICATE_DATA',
        private_key: 'PRIVATE_KEY_DATA',
        private_key_type: 'rsa',
        serial_number: '7e:2d:c8:dd:df:da:fe:1f:39:da:39:23:4f:74:c8:1f:1d:4a:db:a7',
      }

      response = OpenStruct.new(data: @data)
      logical = mock.tap { |object| object.expects(:write).once.with(@pki_path).returns(response) }

      client.expects(:logical).once.returns(logical)
    end

    test 'should return new certificate' do
      assert_equal @data, subject.issue_certificate(@pki_path)
    end
  end
end
