# frozen_string_literal: true

module ForemanVault
  class VaultAuthMethod
    ALLOWED_COMMON_NAMES = ['<FQDN>'].freeze

    def initialize(host)
      @host = host
    end

    def valid?
      name.present? && options[:certificate].present?
    end

    def name
      return if !hostname || !vault_policy_name

      [hostname, vault_policy_name].join('-').parameterize
    end

    def save
      return false unless valid?

      set_certificate(name, options)
    end

    def delete
      return false unless name

      delete_certificate(name)
    end

    private

    attr_reader :host
    delegate :vault_policy, :vault_connection, :hostname, to: :host
    delegate :name, to: :vault_policy, prefix: true
    delegate :set_certificate, :delete_certificate, to: :vault_connection, allow_nil: true

    def options
      {
        certificate: certificate,
        token_policies: name,
        allowed_common_names: ALLOWED_COMMON_NAMES
      }
    end

    def certificate
      return unless Setting['ssl_ca_file']

      File.read(Setting['ssl_ca_file'])
    rescue Errno::ENOENT
      nil
    end
  end
end
