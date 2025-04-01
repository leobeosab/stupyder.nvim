local utils = require("stupyder.utils")
local runner = require("stupyder.runner")
local ui = require("stupyder.ui")
local ts = vim.treesitter

local M = {}

local config = {
    tools = {
        python = {
            cmd = "python3 {filename}"
        },
        c = {
            cmd =  { "gcc {filename} -o {filename}.bin", "{filename}.bin" }
        },
        bash = {
            cmd = { "chmod +x {filename}", "bash {filename}" }
        },
    }
}

local win = nil

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

local createTempFilename = function(language)
    local dir = "/tmp/stupyder"
    local randStr = utils.generateRandomString()
    vim.fn.mkdir(dir, "p")

    local ext = ""

    local languageMap = {
        python = "py",
        c = "c",
    }

    ext = languageMap[language]
    if ext == "" then
        print("not supported")
    end

    return string.format("%s/%s.%s", dir, randStr, ext)
end

local findOrCreateBuffer = function()
end

M.setup = function (opts)
    M.runner = runner:new()
end

M.run_on_cursor = function()
    local block = M.check()
    if block == nil then
        print("nope")
    end

    M.run_code(block.language, block.code)
end

M.run_code = function(language, content)
    if M.runner:is_busy() then
        print("Currently running: " .. M.runner.current_command)
    end
    local tmpFileName = createTempFilename(language)
    local tmpfile = io.open(tmpFileName, "w")
    if not tmpfile then
        print("err")
        return
    end

    if not win then
        win = ui:new()
    end

    win:open()
    win:clear_buff()

    tmpfile:write(content)
    tmpfile:close()

    local runCmd = config.tools[language].cmd
    if type(runCmd) ~= "table" then
        runCmd = { runCmd }
    end

    local cmds = {}

    for _, cmd in ipairs(runCmd) do
        cmd = cmd:gsub("{filename}", tmpFileName)
        table.insert(cmds, cmd)
    end

    M.runner:run_commands(cmds, function(event, data)
        if event == "start" then
            win:append_to_buffer( { string.format("------ Running: %s ------", data.command) } )
        end

        if event == "stdout" or event == "stderr" then
            local lines = {}

            for token in string.gmatch(data, "(.-)\n") do
                table.insert(lines, token)
            end

            win:append_to_buffer(lines)
        end

        if event == "exit" then
            local ec = data
            win:append_to_buffer({ string.format("------ Finished with code: %d ------", ec) })
        end
    end)

end

M.check = function ()
    local blocks = getCodeBlocks()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    for _, v in ipairs(blocks) do
        if utils.isInbetween(current_line, v.loc.start_line, v.loc.end_line) then
            return v
        end
    end

    return nil
end

return M
