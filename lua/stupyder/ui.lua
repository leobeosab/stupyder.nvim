
local M = {}
M.__index = M

function M:new(u)
    u = u or {}

    local window = setmetatable(u, M)
    window.buf = nil
    window.win = nil

    return window
end

local function open_buffer_in_split(buf)
    buf = buf or vim.api.nvim_create_buf(false, true)

    vim.cmd('split')
    vim.cmd('wincmd j')
    vim.cmd('horizontal resize 10')

    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(win, buf)

    return buf, win
end

function M:open(opts)
    local check = self:check_status()

    if check == -1 then
        print("Opening with no buf, but with win")
    end

    if check == -2 then
        _, self.win = open_buffer_in_split(self.buf)
    end

    if check == -3 then 
        self.buf, self.win = open_buffer_in_split()
    end
end

function M:close(close_buff)
    if vim.api.nvim_buf_is_valid(self.buf) then
        vim.api.nvim_buf_delete(self.buf, {})
    end


    self.buf = nil

    if vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_close(self.win, ture)
    end
    self.win = nil
end

function M:clear_buff()
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, {})
end

function M:append_to_buffer(lines)
    local c = self:check_status()
    if c == -1 or c == -3 then
        print("Stupyder buff not valid")
        return
    end

    local current_line = vim.api.nvim_buf_line_count(self.buf) - 1

    vim.api.nvim_buf_set_lines(self.buf, current_line, current_line, false, lines)
end

-- Checks to make sure the window and buffer are valid
-- -1 no buf
-- -2 no win
-- -3 neither
-- 0 good
function M:check_status()
    local ret = 0
    if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
        ret = ret - 1
    end

    if not self.win or not vim.api.nvim_win_is_valid(self.win) then
        ret = ret - 2
    end

    return ret
end

return M
