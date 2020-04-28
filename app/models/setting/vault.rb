# frozen_string_literal: true

class Setting
  class Vault < ::Setting
    def self.default_settings
      [
        set('vault_policy_template', N_('The name of the ProvisioningTemplate that will be used for Vault Policy'), 'Default Vault Policy', N_('Vault Policy template name'))
      ]
    end

    def self.load_defaults
      # Check the table exists
      return unless super

      transaction do
        default_settings.each { |s| create! s.update(category: 'Setting::Vault') }
      end

      true
    end

    def self.humanized_category
      N_('Vault')
    end
  end
end
