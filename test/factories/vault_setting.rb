# frozen_string_literal: true

FactoryBot.modify do
  factory :setting do
    trait :vault_policy do
      name { 'vault_policy_template' }
      value { 'Default Vault Policy' }
    end
  end
end
