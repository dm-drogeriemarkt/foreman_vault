# frozen_string_literal: true

Rails.application.routes.draw do
  resources :vault_connections, except: :show
end
