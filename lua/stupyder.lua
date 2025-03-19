local ts = vim.treesitter

local M = {}

local config = {
    tools = {
        python = {
            cmd = "python3 {filename}"
        }
    }
}

local block_query = ts.query.parse("markdown", [[ (fenced_code_block (info_string (language) @lang) (code_fence_content) @content) ]])

local getCodeBlocks = function ()
    local bufnr = vim.api.nvim_get_current_buf()
    local parser = ts.get_parser(bufnr, "markdown")
    local root = parser:parse()[1]:root()

    local code_blocks = {}

    -- Create and execute the Treesitter query
    for _, match, _ in block_query:iter_matches(root, bufnr, 0, -1) do
        local code_block = {}

        for id, node in pairs(match) do
            local name = block_query.captures[id] -- Name of the capture from the query
            local start_line, _, end_line, _ = node:range()

            if name == "lang" then
                code_block.language = ts.get_node_text(node, bufnr)
            end

            if name == "content" then
                code_block.code = ts.get_node_text(node, bufnr)
                code_block.loc = {
                    start_line = start_line,
                    end_line = end_line
                }
            end

        end

        code_blocks[#code_blocks+1] = code_block
    end

    return code_blocks
end

local isInbetween = function(val, a, b)
    local low = a > b and b or a
    local high = a > b and a or b

    if val >= low and val <= high then
        return true
    end

    return false
end

local generateRandomString = function()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = {}
    for i = 1, 12 do
        local index = math.random(#chars)
        result[i] = chars:sub(index, index)
    end

    return table.concat(result)
end

local createTempFilename = function(language)
    local dir = "/tmp/stupyder"
    local randStr = generateRandomString()
    vim.fn.mkdir(dir, "p")

    local ext = ""

    local languageMap = {
        python = "py"
    }

    ext = languageMap[language]
    if ext == "" then
        print("not supported")
    end

    return string.format("%s/%s.%s", dir, randStr, ext)
end


M.setup = function (opts)

end

M.run_on_cursor = function()
    local block = M.check()
    if block == nil then
        print("nope")
    end

    M.run_code(block.language, block.code)
end

local printStuff = function(jobid, data, event)
    print(vim.inspect(data))
end

M.run_code = function(language, content)
    local tmpFileName = createTempFilename(language)
    local tmpfile = io.open(tmpFileName, "w")
    if not tmpfile then
        print("err")
        return
    end

    tmpfile:write(content)
    tmpfile:close()

    local runCmd = config.tools[language].cmd:gsub("{filename}", tmpFileName)

    local job = vim.fn.jobstart(runCmd, 
    {
        cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"),
        on_exit = printStuff,
        on_stdout = printStuff,
        on_stderr = printStuff
    }
)

end

M.check = function ()
    local blocks = getCodeBlocks()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    for _, v in ipairs(blocks) do
        if isInbetween(current_line, v.loc.start_line, v.loc.end_line) then
            return v
        end
    end

    return nil
end

return M
