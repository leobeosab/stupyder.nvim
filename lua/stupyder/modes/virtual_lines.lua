--TODO add command to clear virtual lines
--TODO virtual output gets fucked with multiple stdout events
--TODO highlights?

local VirtualLineMode = {}
VirtualLineMode.type = "virtual_line_mode"

local content = {}
local location = {}
local ext_mark = nil
local buf_id = -1

function VirtualLineMode:clear()
    content = {}
    if not ext_mark then return end

    vim.api.nvim_buf_del_extmark(
        buf_id,
        vim.api.nvim_create_namespace("stupyder_vl"),
        ext_mark
    )
end

function VirtualLineMode:start(event)
    location = event.run_info.location
    buf_id = vim.api.nvim_get_current_buf()
    self:clear()
end

function VirtualLineMode:append_lines(lines)
    local ns = vim.api.nvim_create_namespace('stupyder_vl')

    for _, v in ipairs(lines) do
        content[#content+1] = {{v}}
    end

    ext_mark = vim.api.nvim_buf_set_extmark(buf_id,
        ns, location.end_line, 0, {
            virt_lines = content,
            id = ext_mark
        }
    )
end

function VirtualLineMode:done()
end

return VirtualLineMode
