# frozen_string_literal: true

module ForemanVault
  module Controller
    module Parameters
      module VaultConnection
        extend ActiveSupport::Concern

        class_methods do
          def vault_connection_params_filter
            Foreman::ParameterFilter.new(::VaultConnection).tap do |filter|
              filter.permit :name, :url, :token
            end
          end
        end

        def vault_connection_params
          self.class.vault_connection_params_filter.filter_params(params, parameter_filter_context)
        end
      end
    end
  end
end
