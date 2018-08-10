# frozen_string_literal: true

Rails.application.routes.draw do
  resources :vault_connections, except: :show

  namespace :api, defaults: { format: 'json' } do
    scope '(:apiv)', module: :v2, defaults: { apiv: 'v2' }, apiv: /v1|v2/, constraints: ApiConstraints.new(version: 2, default: true) do
      resources :vault_connections, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
