local ui = require("stupyder.ui")

local M = {}
local win = ui:new()

function M:start()
    win:open()
    win:clear_buff()
end

function M:append_lines(lines)
    win:append_to_buffer(lines)
end

function M:done()
end

return M
