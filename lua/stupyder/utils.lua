local M = {}

M.dir_sep = package.config:sub(1, 1)

M.ends_with_sep = function(path)
    return path:sub(-1) == M.dir_sep
end

-- This is hacky but there is no way to get the tmp directory without it
-- works for now, thanks @djfdyuruiry
M.get_tmp_dir = function()
    local tmp_file_path = os.tmpname()

    -- remove generated temp file
    pcall(os.remove, tmp_file_path)

    local sep_index = tmp_file_path:reverse():find(M.dir_sep)
    local sub_index = #tmp_file_path - sep_index

    return tmp_file_path:sub(1, sub_index)
end

M.create_temp_filename = function(ext)
    local dir = "/tmp/stupyder"
    vim.fn.mkdir(dir, "p")
    local randStr = M.generateRandomString()
    return string.format("%s/%s.%s", dir, randStr, ext)
end

M.append_to_buffer = function(buff, lines)
    if not vim.api.nvim_buf_is_valid(buff) then
        print("Stupyder buff not valid")
        return
    end

    local current_line = vim.api.nvim_buf_line_count(buff) - 1

    vim.api.nvim_buf_set_lines(buff, current_line, current_line, false, lines)
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

M.table_length = function(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

M.str_includes = function(s, pattern)
    return string.find(s, pattern, 1, true) ~= nil
end

return M
