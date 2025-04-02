local CommandContext = require("stupyder.contexts.command_context")
local NvimContext = require("stupyder.contexts.nvim_context")

return {
    command_context = CommandContext,
    nvim_context = NvimContext
}
