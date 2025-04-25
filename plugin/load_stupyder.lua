vim.api.nvim_create_user_command("Stupyder", function(params)
  local mode = params.args
  require("stupyder").run_on_cursor(mode)
end, {nargs = '?'})
