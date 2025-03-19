vim.api.nvim_create_user_command("RunStupyder", function(params)
  local filename = params.args
  require("stupyder").run_on_cursor()
end, {nargs = '?'})
