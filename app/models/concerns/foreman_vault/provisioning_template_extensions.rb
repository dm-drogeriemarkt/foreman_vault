# frozen_string_literal: true

module ForemanVault
  module ProvisioningTemplateExtensions
    extend ActiveSupport::Concern

    def render(host: nil, params: {}, variables: {}, mode: Foreman::Renderer::REAL_MODE, template_input_values: {}, source_klass: nil)
      source_klass = Foreman::Renderer::Source::Database if template_kind == TemplateKind.find_by(name: 'VaultPolicy')

      super
    end
  end
end
