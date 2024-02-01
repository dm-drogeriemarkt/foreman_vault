# frozen_string_literal: true

module ForemanVault
  class VaultAuthMethod
    def initialize(host)
      @host = host
    end

    def valid?
      name.present? && options[:certificate].present?
    end

    def name
      return unless host

      host.name.parameterize
    end

    def save
      return false unless valid?

      set_certificate(name, options)
    end

    def delete
      return false unless valid?

      delete_certificate(name)
    end

    private

    attr_reader :host

    delegate :vault_policy, :vault_connection, :fqdn, to: :host
    delegate :name, to: :vault_policy, prefix: true
    delegate :set_certificate, :delete_certificate, to: :vault_connection

    def options
      {
        certificate: certificate,
        token_policies: vault_policy_name,
        allowed_common_names: allowed_common_names
      }
    end

    def allowed_common_names
      [fqdn].compact
    end

    def certificate
      return unless Setting['ssl_ca_file']

      File.read(Setting['ssl_ca_file'])
    rescue Errno::ENOENT
      nil
    end
  end
end
