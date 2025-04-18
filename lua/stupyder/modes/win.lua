local ui = require("stupyder.ui")

local WinMode = {}
local win = ui:new()

function WinMode:start()
    win:open()
    win:clear_buff()
end

function WinMode:append_lines(lines)
    win:append_to_buffer(lines)
end

function WinMode:done()
end

return WinMode
