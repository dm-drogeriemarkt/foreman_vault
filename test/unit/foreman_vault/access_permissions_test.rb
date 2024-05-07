# frozen_string_literal: true

require 'test_plugin_helper'
require 'unit/shared/access_permissions_test_base'

# Permissions are added in AccessPermissions with lists of controllers and
# actions that they enable access to.  For non-admin users, we need to test
# that there are permissions available that cover every controller action, else
# it can't be delegated and this will lead to parts of the application that
# aren't functional for non-admin users.
#
# In particular, it's important that actions for AJAX requests are added to
# an appropriate permission so views using those requests function.
class AccessPermissionsTest < ActiveSupport::TestCase
  include AccessPermissionsTestBase

  check_routes(ForemanVault::Engine.routes, [])
end
