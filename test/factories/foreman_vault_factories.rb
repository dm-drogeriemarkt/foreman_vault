# frozen_string_literal: true

FactoryBot.define do
  factory :vault_connection, class: VaultConnection do
    sequence(:name) { |n| "VaultServer-#{n}" }
    url 'http://localhost:8200'
    token '16aa4f29-035d-b604-f3d3-8cd9a6a6921c'
    expire_time { Time.zone.now + 1.year }

    after(:build) { |vault_connection| vault_connection.class.skip_callback(:create, :before, :set_expire_time) }
    after(:build) { |vault_connection| vault_connection.class.skip_callback(:update, :before, :update_expire_time) }
  end
end
