# frozen_string_literal: true

require 'test_plugin_helper'

class VaultPolicyTemplateTest < ActiveSupport::TestCase
  let(:template) { FactoryBot.create(:provisioning_template, :vault_policy) }

  it 'is rendered from a database' do
    Foreman::Renderer.expects(:get_source).with(has_entry(klass: Foreman::Renderer::Source::Database))
    Foreman::Renderer.stubs(:get_scope)
    Foreman::Renderer.stubs(:render)

    template.render
  end
end
