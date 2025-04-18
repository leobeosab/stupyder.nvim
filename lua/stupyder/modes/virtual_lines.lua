local config = require("stupyder.config")
--TODO add command to clear virtual lines

local Mode = {}
Mode.__index = Mode

local location = {}
local ext_marks = {}
local buf_id = -1

function Mode:clear()
    for _, v in pairs(ext_marks) do
        vim.api.nvim_buf_del_extmark(
            buf_id,
            vim.api.nvim_create_namespace("stupyder_vl"),
            v
        )
    end

    ext_marks = {}
end

function Mode:start(event)
    location = event.run_info.location
    buf_id = vim.api.nvim_get_current_buf()
    self:clear()
end

function Mode:append_lines(lines)
    local ns = vim.api.nvim_create_namespace('stupyder_vl')

    local virt_lines = {}
    for _, v in ipairs(lines) do
        virt_lines[#virt_lines+1] = {{v}}
    end

    local mk = vim.api.nvim_buf_set_extmark(buf_id,
        ns, location.end_line, 0, {
            virt_lines = virt_lines
        }
    )

    ext_marks[#ext_marks+1] = mk
end

function Mode:done()
    print("Cancel not implemented for mode")
end

return Mode
