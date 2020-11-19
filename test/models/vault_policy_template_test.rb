# frozen_string_literal: true

require 'test_plugin_helper'

class VaultPolicyTemplateTest < ActiveSupport::TestCase
  let(:host) { FactoryBot.create(:host, :managed) }
  let(:template) { FactoryBot.create(:provisioning_template, :vault_policy) }

  it 'is rendered from a database' do
    Foreman::Renderer.expects(:get_source).with(has_entry(klass: Foreman::Renderer::Source::Database))
    Foreman::Renderer.stubs(:get_scope)
    Foreman::Renderer.stubs(:render)

    template.render
  end

  test 'render in default mode' do
    assert_nothing_raised { template.render(host: host) }
  end

  test 'render in safe mode' do
    assert_nothing_raised { template.render(renderer: Foreman::Renderer::SafeModeRenderer, host: host) }
  end

  test 'render in unsafe mode' do
    assert_nothing_raised { template.render(renderer: Foreman::Renderer::UnsafeModeRenderer, host: host) }
  end
end
