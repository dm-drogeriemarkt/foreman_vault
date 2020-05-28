# frozen_string_literal: true

User.as_anonymous_admin do
  templates = [
    {
      name: 'Default Vault Policy',
      source: 'VaultPolicy/default.erb',
      template_kind: TemplateKind.find_or_create_by(name: 'VaultPolicy')
    }
  ]

  templates.each do |template|
    template[:contents] = File.read(File.join(ForemanVault::Engine.root, 'app/views/unattended/provisioning_templates', template[:source]))

    ProvisioningTemplate.where(name: template[:name]).first_or_create do |pt|
      pt.vendor = 'ForemanVault'
      pt.default = true
      pt.locked = true
      pt.name = template[:name]
      pt.template = template[:contents]
      pt.template_kind = template[:template_kind] if template[:template_kind]
      pt.snippet = template[:snippet] if template[:snippet]
    end
  end
end
