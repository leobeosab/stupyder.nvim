-- TODO add config to not focus output

local ui = require("stupyder.ui")
local config = require("stupyder.config").modes.win

local WinMode = {}
local win = ui:new()

function WinMode:start()
    win:open({
        close_shortcut = config.close_shortcut,
        win_config = config.win_config
    })
    win:clear_buff()
end

function WinMode:append_lines(lines)
    win:append_to_buffer(lines)
end

function WinMode:append_errors(lines)
    self:append_lines(lines)
end

function WinMode:done()
end

return WinMode
