# frozen_string_literal: true

FactoryBot.modify do
  factory :provisioning_template do
    trait :vault_policy do
      name { Setting['vault_policy_template'] || 'Default Vault Policy' }
      template_kind { TemplateKind.find_or_create_by(name: 'VaultPolicy') }
      template { File.read(File.join(ForemanVault::Engine.root, 'app/views/unattended/provisioning_templates/VaultPolicy/default.erb')) }
    end
  end
end
