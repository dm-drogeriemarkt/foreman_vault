# frozen_string_literal: true

module ForemanVault
  class VaultPolicy
    MAGIC_COMMENT_NAME_PREFIX = '# NAME: '

    def initialize(host)
      @host = host
    end

    def valid?
      name.present? && rules.present?
    end

    def name
      magic_comment_name&.chomp&.remove(MAGIC_COMMENT_NAME_PREFIX)&.parameterize
    end

    def new?
      return unless name

      policies.index(name).nil?
    end

    def save
      return false unless valid?

      put_policy(name, rules)
    end

    def delete
      return false unless name

      delete_policy(name)
    end

    private

    attr_reader :host
    delegate :params, :render_template, :vault_connection, to: :host
    delegate :policy, :policies, :put_policy, :delete_policy, to: :vault_connection, allow_nil: true

    def rules
      rendered&.remove(magic_comment_name)
              &.lines
              &.reject { |l| l.strip.empty? }
              &.join
              &.presence
    end

    def magic_comment_name
      rendered&.lines&.find { |l| l.start_with?(MAGIC_COMMENT_NAME_PREFIX) }
    end

    def rendered
      return unless template

      render_template(template: template)
    end

    def template
      ::ProvisioningTemplate.find_by(name: Setting['vault_policy_template'])
    end
  end
end
