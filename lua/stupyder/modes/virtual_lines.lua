local config = require("stupyder.config")

local Mode = {}
Mode.__index = Mode

local location = {}

function Mode:start(event)
    location = event.run_info.location

    vim.api.nvim_buf_clear_namespace(vim.api.nvim_get_current_buf(),
        vim.api.nvim_create_namespace('stupyder_vl'),
    0, 1)
end

function Mode:append_lines(lines)
    local ns = vim.api.nvim_create_namespace('stupyder_vl')

    local virt_lines = {}
    for _, v in ipairs(lines) do
        virt_lines[#virt_lines+1] = {{v}}
    end

    vim.api.nvim_buf_set_extmark(vim.api.nvim_get_current_buf(),
        ns, location.end_line, 0, {
            virt_lines = virt_lines
        }
    )
end

function Mode:done()
    print("Cancel not implemented for mode")
end

return Mode
