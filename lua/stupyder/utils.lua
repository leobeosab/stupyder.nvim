

local M = {}

M.runCommand = function (command, onRead, onExit)
    local argsTable = {}

    for token in string.gmatch(command, "[^%s]+") do
        table.insert(argsTable, token)
    end

    local path = table.remove(argsTable, 1)

    local stdout = vim.uv.new_pipe(false)
    local stderr = vim.uv.new_pipe(false)

    local handle
    local function on_exit(_, exit_code, _)
        vim.schedule(function() onExit(exit_code) end)
        stdout:close()
        stderr:close()
        handle:close()
    end

    handle = vim.uv.spawn(path, {
        args = argsTable,
        stdio = {nil, stdout, stderr}
    }, on_exit)

    local function on_read(pipe, err, data)
        assert(not err, err)
        if data then
            vim.schedule(function()
                onRead(pipe, data)
            end)
        end
    end

    stdout:read_start(function(err, data)
        on_read(stdout, err, data)
    end)

    stderr:read_start(function(err, data)
        on_read(stderr, err, data)
    end)
end

M.append_to_buffer = function(buff, lines)
    if not vim.api.nvim_buf_is_valid(buff) then
        print("Stupyder buff not valid")
        return
    end

    local current_line = vim.api.nvim_buf_line_count(buff) - 1

    vim.api.nvim_buf_set_lines(buff, current_line, current_line, false, lines)
end

M.open_buffer_in_split = function(buf)
    buf = buf or vim.api.nvim_create_buf(false, true)

    vim.cmd('split')
    vim.cmd('wincmd j')
    vim.cmd('horizontal resize 10')

    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(win, buf)

    return buf, win
end

M.generateRandomString = function()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = {}
    for i = 1, 12 do
        local index = math.random(#chars)
        result[i] = chars:sub(index, index)
    end

    return table.concat(result)
end

M.isInbetween = function(val, a, b)
    local low = a > b and b or a
    local high = a > b and a or b

    if val >= low and val <= high then
        return true
    end

    return false
end

return M
