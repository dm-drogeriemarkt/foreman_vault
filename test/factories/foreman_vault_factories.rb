# frozen_string_literal: true

FactoryBot.define do
  factory :vault_connection, class: VaultConnection do
    sequence(:name) { |n| "VaultServer-#{n}" }
    url 'http://localhost:8200'
    token '16aa4f29-035d-b604-f3d3-8cd9a6a6921c'
    expire_time { Time.zone.now + 1.year }

    trait :without_callbacks do
      after(:build) do |user|
        class << user
          def set_expire_time
            true
          end

          def update_expire_time
            true
          end
        end
      end
    end
  end
end
