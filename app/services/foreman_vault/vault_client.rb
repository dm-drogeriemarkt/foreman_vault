# frozen_string_literal: true

require 'net/http'

module ForemanVault
  class VaultClient
    def initialize(base_url, token)
      @base_url = base_url
      @token = token
    end

    def token_expires_at
      json = post('/v1/auth/token/lookup')
      Time.zone.parse(json['data']['expire_time'])
    end

    private

    attr_reader :base_url, :token

    class VaultClientError < Foreman::Exception; end
    class InvalidURIError < VaultClientError; end
    class ConnectionRefusedError < VaultClientError; end
    class HTTPClientError < VaultClientError; end
    class HTTPServerError < VaultClientError; end

    def get(path, headers: {})
      request = Net::HTTP::Get.new(path)
      headers.merge('X-Vault-Token': token).each { |k, v| request.add_field(k, v) }
      call(request)
    end

    def post(path, headers: {}, body: '')
      request = Net::HTTP::Post.new(path)
      headers.merge('X-Vault-Token': token).each { |k, v| request.add_field(k, v) }
      request.body = body
      call(request)
    end

    def put(path, headers: {}, body: '')
      request = Net::HTTP::Put.new(path)
      headers.merge('X-Vault-Token': token).each { |k, v| request.add_field(k, v) }
      request.body = body
      call(request)
    end

    def delete(path, headers: {})
      request = Net::HTTP::Delete.new(path)
      headers.merge('X-Vault-Token': token).each { |k, v| request.add_field(k, v) }
      call(request)
    end

    def call(request)
      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(request)
      json(response)
    rescue URI::InvalidURIError
      raise InvalidURIError, 'Invalid URI'
    rescue Errno::ECONNREFUSED
      raise ConnectionRefusedError, 'Connection refused'
    end

    def json(response)
      case response
      when Net::HTTPSuccess       then JSON.parse(response.body)
      when Net::HTTPClientError   then raise HTTPClientError, "#{response.code}: #{response.message}"
      when Net::HTTPServerError   then raise HTTPServerError, "#{response.code}: #{response.message}"
      else raise VaultClientError, "#{response.code}: #{response.message}"
      end
    end
  end
end
