local config = require("stupyder.config")

describe('Test config merging', function()
  local userConfig = {
    run_options = { print_debug_info = true },
    modes = {
      yank = { register = '"' }
    }
  }

  config:apply_user_config(userConfig)

  assert.are.equal(config.run_options, { print_debug_info = true, default_mode = "virtual_lines" })
end)
