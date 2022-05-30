# frozen_string_literal: true

require 'test_plugin_helper'

class VaultConnectionTest < ActiveSupport::TestCase
  subject { FactoryBot.create(:vault_connection, :without_callbacks) }
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should validate_presence_of(:token)
  should validate_presence_of(:url)
  should allow_value('http://127.0.0.1:8200').for(:url)
  should_not allow_value('börks').for(:url)

  test 'validate that the name cannot be changed' do
    assert_raises(ActiveRecord::RecordInvalid, 'Validation failed: Name cannot be changed after creation') do
      subject.update!(name: 'UpdatedName')
    end
  end
end
